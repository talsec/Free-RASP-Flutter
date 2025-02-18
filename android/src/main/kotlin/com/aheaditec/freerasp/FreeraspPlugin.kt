package com.aheaditec.freerasp

import android.content.Context
import android.os.Build
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.aheaditec.freerasp.handlers.MethodCallHandler
import com.aheaditec.freerasp.handlers.StreamHandler
import com.aheaditec.freerasp.handlers.TalsecThreatHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter

/** FreeraspPlugin */
class FreeraspPlugin : FlutterPlugin, ActivityAware, LifecycleEventObserver {
    private var streamHandler: StreamHandler = StreamHandler()
    private var methodCallHandler: MethodCallHandler = MethodCallHandler()
    private var screenProtector: ScreenProtector? =
        if (Build.VERSION.SDK_INT >= 34) ScreenProtector() else null

    private var context: Context? = null
    private var lifecycle: Lifecycle? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.binaryMessenger
        context = flutterPluginBinding.applicationContext
        screenProtector?.enable()
        methodCallHandler.createMethodChannel(messenger, flutterPluginBinding.applicationContext)
        streamHandler.createEventChannel(messenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodCallHandler.destroyMethodChannel()
        streamHandler.destroyEventChannel()
        TalsecThreatHandler.detachListener(binding.applicationContext)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding).also {
            it.addObserver(this)
        }
        methodCallHandler.activity = binding.activity
        screenProtector?.activity = binding.activity
        screenProtector?.let { lifecycle?.addObserver(it) }
    }

    override fun onDetachedFromActivity() {
        lifecycle?.removeObserver(this)
        methodCallHandler.activity = null
        screenProtector?.let { lifecycle?.removeObserver(it) }
        screenProtector?.activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        lifecycle?.removeObserver(this)
        methodCallHandler.activity = null
        screenProtector?.let { lifecycle?.removeObserver(it) }
        screenProtector?.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
        lifecycle?.addObserver(this)
        methodCallHandler.activity = binding.activity
        screenProtector?.activity = binding.activity
        screenProtector?.let { lifecycle?.addObserver(it) }

    }

    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
        when (event) {
            Lifecycle.Event.ON_RESUME -> context?.let { TalsecThreatHandler.resumeListener() }
            Lifecycle.Event.ON_PAUSE -> context?.let { TalsecThreatHandler.suspendListener() }
            else -> {
                // Nothing to do
            }
        }
    }
}
