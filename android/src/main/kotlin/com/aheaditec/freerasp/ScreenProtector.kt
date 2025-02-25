package com.aheaditec.freerasp

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Activity.ScreenCaptureCallback
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.view.WindowManager.SCREEN_RECORDING_STATE_VISIBLE
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.aheaditec.talsec_security.security.api.Talsec
import io.flutter.Log
import java.util.function.Consumer

internal class ScreenProtector : DefaultLifecycleObserver {
    companion object {
        private const val TAG = "ScreenProtector"
        private const val SCREEN_CAPTURE_PERMISSION = "android.permission.DETECT_SCREEN_CAPTURE"
        private const val SCREEN_RECORDING_PERMISSION = "android.permission.DETECT_SCREEN_RECORDING"
    }

    internal var activity: Activity? = null
    private var isEnabled = false

    private val screenCaptureCallback = ScreenCaptureCallback { Talsec.onScreenshotDetected() }
    private val screenRecordCallback: Consumer<Int> = Consumer<Int> { state ->
        if (state == SCREEN_RECORDING_STATE_VISIBLE) {
            Talsec.onScreenRecordingDetected()
            Log.e("ScreenProtector", "Screen recording detected")
        }
    }

    internal fun enable() {
        if (isEnabled) return
        isEnabled = true
        activity?.let { register(it) }
    }

    override fun onStart(owner: LifecycleOwner) {
        super.onStart(owner)

        if (isEnabled) activity?.let { register(it) }
    }

    override fun onStop(owner: LifecycleOwner) {
        super.onStop(owner)

        if (isEnabled) activity?.let { unregister(it) }
    }

    private fun register(activity: Activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            registerScreenCapture(activity)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            registerScreenRecording(activity)
        }
    }

    // Missing permission is suppressed because the decision to use the screen capture API is made
    // by developer, and not enforced by the library.
    @SuppressLint("MissingPermission")
    private fun unregister(currentActivity: Activity) {
        val context = currentActivity.applicationContext

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE && hasPermission(
                context, SCREEN_CAPTURE_PERMISSION
            )
        ) {
            currentActivity.unregisterScreenCaptureCallback(screenCaptureCallback)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM && hasPermission(
                context, SCREEN_RECORDING_PERMISSION
            )
        ) {
            currentActivity.windowManager?.removeScreenRecordingCallback(screenRecordCallback)
        }
    }

    // Missing permission is suppressed because the decision to use the screen capture API is made
    // by developer, and not enforced by the library.
    @SuppressLint("MissingPermission")
    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    private fun registerScreenCapture(currentActivity: Activity) {
        val context = currentActivity.applicationContext

        if (!hasPermission(context, SCREEN_CAPTURE_PERMISSION)) {
            reportMissingPermission("screenshot", SCREEN_CAPTURE_PERMISSION)
            return
        }

        currentActivity.registerScreenCaptureCallback(context.mainExecutor, screenCaptureCallback)
    }

    // Missing permission is suppressed because the decision to use the screen capture API is made
    // by developer, and not enforced by the library.
    @SuppressLint("MissingPermission")
    @RequiresApi(Build.VERSION_CODES.VANILLA_ICE_CREAM)
    private fun registerScreenRecording(currentActivity: Activity) {
        val context = currentActivity.applicationContext

        if (!hasPermission(context, SCREEN_RECORDING_PERMISSION)) {
            reportMissingPermission("screen record", SCREEN_RECORDING_PERMISSION)
            return
        }

        val initialState = currentActivity.windowManager.addScreenRecordingCallback(
            context.mainExecutor, screenRecordCallback
        )
        screenRecordCallback.accept(initialState)

    }

    private fun hasPermission(context: Context, permission: String): Boolean {
        return ContextCompat.checkSelfPermission(
            context, permission
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun reportMissingPermission(protectionType: String, permission: String) {
        Log.e(
            TAG,
            "Failed to register $protectionType callback. Check if $permission permission is granted in AndroidManifest.xml"
        )
    }
}