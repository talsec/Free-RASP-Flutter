package com.aheaditec.freerasp.handlers

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.aheaditec.freerasp.Utils
import com.aheaditec.freerasp.generated.RaspExecutionState
import com.aheaditec.freerasp.runResultCatching
import com.aheaditec.freerasp.generated.TalsecPigeonApi
import com.aheaditec.freerasp.toPigeon
import com.aheaditec.talsec_security.security.api.SuspiciousAppInfo
import com.aheaditec.talsec_security.security.api.Talsec
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/**
 * A method handler that creates and manages an [MethodChannel] for freeRASP methods.
 */
internal class MethodCallHandler : MethodCallHandler, LifecycleEventObserver {
    private var context: Context? = null
    private var methodChannel: MethodChannel? = null
    private var talsecPigeon: TalsecPigeonApi? = null
    private var raspExecutionPigeon : RaspExecutionState? = null
    private val backgroundHandlerThread = HandlerThread("BackgroundThread").apply { start() }
    private val backgroundHandler = Handler(backgroundHandlerThread.looper)
    private val mainHandler = Handler(Looper.getMainLooper())

    internal var activity: Activity? = null

    companion object {
        private const val CHANNEL_NAME: String = "talsec.app/freerasp/methods"
    }

    private val sink = object : MethodSink {
        override fun onMalwareDetected(packageInfo: List<SuspiciousAppInfo>) {
            context?.let { context ->
                val pigeonPackageInfo = packageInfo.map { it.toPigeon(context) }
                talsecPigeon?.onMalwareDetected(pigeonPackageInfo) { result ->
                    // Parse the result (which is Unit so we can ignore it) or throw an exception
                    // Exceptions are translated to Flutter errors automatically
                    result.getOrElse {
                        Log.e("MethodCallHandlerSink", "Result ended with failure")
                        throw it
                    }
                }
            }
        }

        override fun onAllChecksFinished() {
            raspExecutionPigeon?.onAllChecksFinished { result ->
                // Parse the result (which is Unit so we can ignore it) or throw an exception
                // Exceptions are translated to Flutter errors automatically
                result.getOrElse {
                    Log.e("MethodCallHandlerSink", "Result ended with failure")
                    throw it
                }
            }
        }
    }

    internal interface MethodSink {
        fun onMalwareDetected(packageInfo: List<SuspiciousAppInfo>)
        fun onAllChecksFinished()
    }

    /**
     * Creates a new [MethodChannel] with the specified [BinaryMessenger] instance. Sets this class
     * as the [MethodCallHandler].
     * If an old [MethodChannel] already exists, it will be destroyed before creating a new one.
     *
     * @param messenger The binary messenger to use for creating the [MethodChannel].
     * @param context The Android [Context] associated with this channel.
     */
    fun createMethodChannel(messenger: BinaryMessenger, context: Context) {
        methodChannel?.let {
            Log.i("MethodCallHandler", "Tried to create channel without disposing old one.")
            destroyMethodChannel()
        }

        methodChannel = MethodChannel(messenger, CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }

        this.context = context
        this.talsecPigeon = TalsecPigeonApi(messenger)
        this.raspExecutionPigeon = RaspExecutionState(messenger)

        TalsecThreatHandler.attachMethodSink(sink)
    }

    /**
     * Destroys the `MethodChannel` and clears associated variables.
     */
    fun destroyMethodChannel() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        this.context = null
        this.talsecPigeon = null
        this.raspExecutionPigeon = null

        TalsecThreatHandler.detachMethodSink()
    }

    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
        when (event) {
            Lifecycle.Event.ON_DESTROY -> {
                context?.let {
                    backgroundHandlerThread.quitSafely()
                }
            }

            else -> {
                // Nothing to do
            }
        }
    }

    /**
     * Handles method calls received through the [MethodChannel].
     *
     * @param call The method call.
     * @param result The result handler of the method call.
     */
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> start(call, result)
            "addToWhitelist" -> addToWhitelist(call, result)
            "getAppIcon" -> getAppIcon(call, result)
            "blockScreenCapture" -> blockScreenCapture(call, result)
            "isScreenCaptureBlocked" -> isScreenCaptureBlocked(result)
            "storeExternalId" -> storeExternalId(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * Starts freeRASP
     *
     * @param call The method call containing the configuration.
     * @param result The result handler of the method call.
     */
    private fun start(call: MethodCall, result: MethodChannel.Result) {
        runResultCatching(result) {
            val config = call.argument<String>("config")
            val talsecConfig = Utils.toTalsecConfigThrowing(config)
            context?.let {
                TalsecThreatHandler.start(it, talsecConfig)
            } ?: throw IllegalStateException("Unable to run Talsec - context is null")
            result.success(null)
        }
    }

    private fun addToWhitelist(call: MethodCall, result: MethodChannel.Result) {
        runResultCatching(result) {
            val packageName = call.argument<String>("packageName")
            context?.let {
                if (packageName != null) {
                    Talsec.addToWhitelist(it, packageName)
                }
            } ?: throw IllegalStateException("Unable to add package to whitelist - context is null")
            result.success(null)
        }
    }

    /**
     * Retrieves app icon for the given package name.
     *
     * @param call The method call containing the package name.
     * @param result The result handler of the method call.
     */
    private fun getAppIcon(call: MethodCall, result: MethodChannel.Result) {
        runResultCatching(result) {
            val packageName = call.argument<String>("packageName")
                ?: throw NullPointerException("Package name cannot be null.")

            backgroundHandler.post {
                context?.let {
                    val appIcon = Utils.parseIconBase64(it, packageName)
                    mainHandler.post { result.success(appIcon) }
                }
            }

        }
    }

    /**
     * Blocks or unblocks screen capture. Sets the window flag to secure the screen.
     *
     * @param call The method call containing the enable flag.
     * @param result The result handler of the method call.
     */
    private fun blockScreenCapture(call: MethodCall, result: MethodChannel.Result) {
        runResultCatching(result) {
            val enable = call.argument<Boolean>("enable") == true
            context?.let {
                Talsec.blockScreenCapture(it, enable)
                result.success(null)
                return@runResultCatching
            }
            throw IllegalStateException("Unable to block screen capture - context is null")
        }
    }

    /**
     * Checks if screen capture is blocked.
     *
     * @param result The result handler of the method call.
     */
    private fun isScreenCaptureBlocked(result: MethodChannel.Result) {
        runResultCatching(result) {
            result.success(Talsec.isScreenCaptureBlocked())
        }
    }

    /**
     * Stores an external ID.
     *
     * @param call The method call containing the external ID.
     * @param result The result handler of the method call.
     */
    private fun storeExternalId(call: MethodCall, result: MethodChannel.Result) {
        runResultCatching(result) {
            context?.let {
                val data = call.argument<String>("data")
                if (data == null) {
                    throw NullPointerException("External ID data cannot be null.")
                }
                Talsec.storeExternalId(it, data)
                result.success(null)
                return@runResultCatching
            }
            throw IllegalStateException("Unable to store external ID - context is null")
        }
    }
}
