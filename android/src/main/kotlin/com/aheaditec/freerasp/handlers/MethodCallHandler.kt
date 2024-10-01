package com.aheaditec.freerasp.handlers

import android.content.Context
import com.aheaditec.freerasp.runResultCatching
import com.aheaditec.freerasp.Utils
import com.aheaditec.freerasp.generated.TalsecPigeonApi
import com.aheaditec.freerasp.getOrElseThenThrow
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
internal class MethodCallHandler : MethodCallHandler {
    private var context: Context? = null
    private var methodChannel: MethodChannel? = null
    private var pigeonApi: TalsecPigeonApi? = null

    companion object {
        private const val CHANNEL_NAME: String = "talsec.app/freerasp/methods"
    }

    private val sink = object : MethodSink {
        override fun onMalwareDetected(packageInfo: List<SuspiciousAppInfo>) {
            context?.let { context ->
                val pigeonPackageInfo = packageInfo.map { it.toPigeon(context) }
                pigeonApi?.onMalwareDetected(pigeonPackageInfo) { result ->
                    // Parse the result (which is Unit so we can ignore it) or throw an exception
                    // Exceptions are translated to Flutter errors automatically
                    result.getOrElseThenThrow {
                        Log.e("MethodCallHandlerSink", "Result ended with failure")
                    }
                }
            }
        }
    }

    internal interface MethodSink {
        fun onMalwareDetected(packageInfo: List<SuspiciousAppInfo>)
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
        this.pigeonApi = TalsecPigeonApi(messenger)

        TalsecThreatHandler.attachMethodSink(sink)
    }

    /**
     * Destroys the `MethodChannel` and clears associated variables.
     */
    fun destroyMethodChannel() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        this.context = null
        this.pigeonApi = null

        TalsecThreatHandler.detachMethodSink()
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
}
