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

@SuppressLint("StaticFieldLeak")
internal object ScreenProtector {
    private const val TAG = "TalsecScreenProtector"
    private const val SCREEN_CAPTURE_PERMISSION = "android.permission.DETECT_SCREEN_CAPTURE"
    private const val SCREEN_RECORDING_PERMISSION = "android.permission.DETECT_SCREEN_RECORDING"

    private var isEnabled = false
    private var isRegistered = false

    private val cachedThreats = mutableSetOf<Threat>()
    private val screenCaptureCallback = ScreenCaptureCallback { handleThreat(Threat.Screenshot) }
    private val screenRecordCallback: Consumer<Int> = Consumer<Int> { state ->
        if (state == SCREEN_RECORDING_STATE_VISIBLE) handleThreat(Threat.ScreenRecording)
    }

    fun enable() {
        if (isEnabled) return

        isEnabled = true
        cachedThreats.forEach { handleThreat(it) }
        cachedThreats.clear()
    }

    fun disable() {
        isEnabled = false
    }

    internal fun register(activity: Activity) {
        if (isRegistered) {
            android.util.Log.w(TAG, "ScreenProtector is already registered.")
            return
        }

        if (Build.VERSION.SDK_INT >= 34) {
            registerScreenCapture(activity)
        }

        if (Build.VERSION.SDK_INT >= 35) {
            registerScreenRecording(activity)
        }

        isRegistered = true
    }

    // Missing permission is suppressed because the decision to use the screen capture API is made
    // by developer, and not enforced by the library.
    @SuppressLint("MissingPermission")
    @RequiresApi(34)
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
    @RequiresApi(35)
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

    // Missing permission is suppressed because the decision to use the screen capture API is made
    // by developer, and not enforced by the library.
    @SuppressLint("MissingPermission")
    internal fun unregister(currentActivity: Activity) {
        if (!isRegistered) {
            android.util.Log.w(TAG, "ScreenProtector is not registered.")
            return
        }

        val context = currentActivity.applicationContext

        if (Build.VERSION.SDK_INT >= 34 && hasPermission(
                context, SCREEN_CAPTURE_PERMISSION
            )
        ) {
            currentActivity.unregisterScreenCaptureCallback(screenCaptureCallback)
        }

        if (Build.VERSION.SDK_INT >= 35 && hasPermission(
                context, SCREEN_RECORDING_PERMISSION
            )
        ) {
            currentActivity.windowManager?.removeScreenRecordingCallback(screenRecordCallback)
        }

        isRegistered = false
    }

    private fun hasPermission(context: Context, permission: String): Boolean {
        return ContextCompat.checkSelfPermission(
            context, permission
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun reportMissingPermission(protectionType: String, permission: String) {
        android.util.Log.e(
            TAG,
            "Failed to register $protectionType callback. Check if $permission permission is granted in AndroidManifest.xml"
        )
    }

    private fun handleThreat(threat: Threat) {
        if (!isEnabled) {
            cachedThreats.add(threat)
            return
        }

        when (threat) {
            Threat.Screenshot -> Talsec.onScreenshotDetected()
            Threat.ScreenRecording -> Talsec.onScreenRecordingDetected()
            else -> throw IllegalArgumentException("Unexpected Threat type: $threat")
        }
    }
}
