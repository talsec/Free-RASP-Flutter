package com.aheaditec.freerasp.handlers

import android.content.Context
import com.aheaditec.talsec_security.security.api.SuspiciousAppInfo
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/**
 * A method handler that creates and manages an [MethodChannel] for freeRASP methods.
 */
internal class MethodCallInvoker: MethodCallHandler {
    private var context: Context? = null
    private var methodChannel: MethodChannel? = null
    private val methodSink = object : MethodSink {
        override fun onMalwareDetected(packageInfo: List<SuspiciousAppInfo>) {
            methodChannel?.invokeMethod("onMalwareDetected", mapOf("packageInfo" to packageInfo.map { }))
        }
    }

    companion object {
        private const val CHANNEL_NAME: String = "talsec.app/freerasp/invoke"
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
        TalsecThreatHandler.attachMethodSink(methodSink)
    }

    /**
     * Destroys the `MethodChannel` and clears associated variables.
     */
    fun destroyMethodChannel() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        this.context = null
        TalsecThreatHandler.detachMethodSink()
    }

    /**
     * Handles method calls received through the [MethodChannel].
     *
     * @param call The method call.
     * @param result The result handler of the method call.
     */
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        result.error("INVALID", "This channel does not handle calls from Flutter.", null)
    }
}
