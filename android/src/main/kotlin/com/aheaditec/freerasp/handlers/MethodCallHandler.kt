package com.aheaditec.freerasp.handlers

import android.content.Context
import com.aheaditec.freerasp.CaptureType
import com.aheaditec.freerasp.runResultCatching
import com.aheaditec.freerasp.utils.Utils
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

    companion object {
        private const val CHANNEL_NAME: String = "talsec.app/freerasp/methods"
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

        TalsecThreatHandler.attachMethod(sink)
        this.context = context
    }

    /**
     * Destroys the `MethodChannel` and clears associated variables.
     */
    fun destroyMethodChannel() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        TalsecThreatHandler.detachMethod()
        this.context = null
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
            val extendedTalsecConfig = Utils.toExtendedTalsecConfigThrowing(config)
            context?.let {
                TalsecThreatHandler.start(it, extendedTalsecConfig)
            } ?: throw IllegalStateException("Unable to run Talsec - context is null")
            result.success(null)
        }
    }

    private val sink = object : MethodSink {
        override fun onScreenCaptureDetected(captureType: CaptureType) {
            methodChannel?.invokeMethod(
                "onScreenCaptureDetected",
                mapOf(Pair("type", captureType.value))
            )
        }
    }

    internal interface MethodSink {
        fun onScreenCaptureDetected(captureType: CaptureType)
    }
}