package com.aheaditec.freerasp

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Activity.ScreenCaptureCallback
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import android.view.WindowManager.SCREEN_RECORDING_STATE_VISIBLE
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import com.aheaditec.talsec_security.security.api.Talsec
import java.util.function.Consumer

internal object ScreenProtector {
    private const val TAG = "TalsecScreenProtector"
    private const val SCREEN_CAPTURE_PERMISSION = "android.permission.DETECT_SCREEN_CAPTURE"
    private const val SCREEN_RECORDING_PERMISSION = "android.permission.DETECT_SCREEN_RECORDING"

    private val screenCaptureCallback = ScreenCaptureCallback { Talsec.onScreenshotDetected() }
    private val screenRecordCallback: Consumer<Int> = Consumer<Int> { state ->
        if (state == SCREEN_RECORDING_STATE_VISIBLE) {
            Talsec.onScreenRecordingDetected()
        }
    }

    internal fun register(activity: Activity, context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            registerScreenCapture(activity, context)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            registerScreenRecording(activity, context)
        }
    }

    // Missing permission is suppressed because the decision to use the screen capture API is made
    // by developer, and not enforced by the library.
    @SuppressLint("MissingPermission")
    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    private fun registerScreenCapture(activity: Activity, context: Context) {
        if (!hasPermission(context, SCREEN_CAPTURE_PERMISSION)) {
            reportMissingPermission("screenshot", SCREEN_CAPTURE_PERMISSION)
            return
        }

        activity.registerScreenCaptureCallback(context.mainExecutor, screenCaptureCallback)
    }

    // Missing permission is suppressed because the decision to use the screen capture API is made
    // by developer, and not enforced by the library.
    @SuppressLint("MissingPermission")
    @RequiresApi(Build.VERSION_CODES.VANILLA_ICE_CREAM)
    private fun registerScreenRecording(activity: Activity, context: Context) {
        if (!hasPermission(context, SCREEN_RECORDING_PERMISSION)) {
            reportMissingPermission("screen record", SCREEN_RECORDING_PERMISSION)
            return
        }

        activity.windowManager.addScreenRecordingCallback(
            context.mainExecutor, screenRecordCallback
        )
    }

    // Missing permission is suppressed because the decision to use the screen capture API is made
    // by developer, and not enforced by the library.
    @SuppressLint("MissingPermission")
    internal fun unregister(activity: Activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            activity.unregisterScreenCaptureCallback(screenCaptureCallback)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            activity.windowManager?.removeScreenRecordingCallback(screenRecordCallback)
        }
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