package com.aheaditec.freerasp

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FreeraspPlugin */
class FreeraspPlugin : FlutterPlugin {
    private lateinit var methodCallHandler: MethodCallHandlerImpl
    private lateinit var streamHandler: StreamHandlerImpl
    private lateinit var talsecApp: TalsecApp

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodCallHandler = MethodCallHandlerImpl()
        methodCallHandler.createMethodChannel(flutterPluginBinding.binaryMessenger)
        streamHandler = StreamHandlerImpl()
        streamHandler.createEventChannel(flutterPluginBinding.binaryMessenger)
        initTalsec(flutterPluginBinding.applicationContext)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodCallHandler.destroyMethodChannel()
        streamHandler.destroyEventChannel()
    }

    private fun initTalsec(context: Context){
        talsecApp = TalsecApp(context)
        methodCallHandler.talsecApp = talsecApp
        streamHandler.talsecApp = talsecApp
    }
}
