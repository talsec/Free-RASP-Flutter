package com.aheaditec.freerasp

import android.app.Activity
import android.content.Context
import android.os.Build
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.aheaditec.freerasp.handlers.ExecutionStateStreamHandler
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
    private var executionStateStreamHandler: ExecutionStateStreamHandler = ExecutionStateStreamHandler()
    private var methodCallHandler: MethodCallHandler = MethodCallHandler()
    private var screenProtector: ScreenProtector? =
        if (Build.VERSION.SDK_INT >= 34) ScreenProtector else null

    private var context: Context? = null
    private var lifecycle: Lifecycle? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.binaryMessenger
        context = flutterPluginBinding.applicationContext
        methodCallHandler.createMethodChannel(messenger, flutterPluginBinding.applicationContext)
        streamHandler.createEventChannel(messenger)
        executionStateStreamHandler.createEventChannel(messenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodCallHandler.destroyMethodChannel()
        streamHandler.destroyEventChannel()
        executionStateStreamHandler.destroyEventChannel()
        TalsecThreatHandler.detachListener(binding.applicationContext)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding).also {
            it.addObserver(this)
        }
        screenProtector?.register(binding.activity)
        methodCallHandler.activity = binding.activity
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        lifecycle?.removeObserver(this)
        screenProtector?.unregister(activity!!)
        methodCallHandler.activity = null
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        lifecycle?.removeObserver(this)
        screenProtector?.unregister(activity!!)
        methodCallHandler.activity = null
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
        activity = binding.activity
        methodCallHandler.activity = binding.activity
        lifecycle?.addObserver(this)
        screenProtector?.register(binding.activity)
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
