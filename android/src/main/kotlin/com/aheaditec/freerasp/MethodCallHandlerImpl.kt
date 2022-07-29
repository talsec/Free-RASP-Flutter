package com.aheaditec.freerasp

import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MethodCallHandlerImpl : MethodCallHandler {

    var talsecApp: TalsecApp? = null
    private var methodChannel: MethodChannel? = null

    companion object {
        private const val CHANNEL_NAME: String = "plugins.aheaditec.com/config"
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "setConfig") {
            init(call, result)
            return
        }
        result.error("ON_METHOD_CALL", "Unexpected function call", null)
    }

    fun createMethodChannel(messenger: BinaryMessenger) {
        if (methodChannel != null) {
            Log.w(
                "MethodCallHandlerImpl",
                "Tried to set method handler when last instance was not destroyed."
            )
            methodChannel = null
            destroyMethodChannel()
        }
        methodChannel = MethodChannel(messenger, CHANNEL_NAME).also {
            it.setMethodCallHandler(this)
        }
    }

    fun destroyMethodChannel() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }

    private fun init(call: MethodCall, result: Result) {
        try {
            val packageName = call.argument<String>("expectedPackageName")
            val signingHash = call.argument<String>("expectedSigningCertificateHash")
            val watcherMail = call.argument<String>("watcherMail")
            val supportedStores = call.argument<List<String>>("supportedAlternativeStores")

            if (packageName != null && signingHash != null && watcherMail != null && supportedStores != null) {
                talsecApp?.init(
                    packageName,
                    signingHash,
                    watcherMail,
                    supportedStores.toTypedArray()
                ) ?: Log.w("SET_CONFIG", "Tried to initialize null Talsec object")
            }
        } catch (ex: Exception) {
            result.error("SET_CONFIG", "An error occurred during initialization: $ex", null)
        }
    }
}