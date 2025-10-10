package com.aheaditec.freerasp.handlers

import android.content.Context
import android.os.Build
import com.aheaditec.freerasp.ScreenProtector
import com.aheaditec.freerasp.Threat
import com.aheaditec.talsec_security.security.api.SuspiciousAppInfo
import com.aheaditec.talsec_security.security.api.Talsec
import com.aheaditec.talsec_security.security.api.TalsecConfig
import io.flutter.plugin.common.EventChannel.EventSink

/**
 * Object responsible for managing the event channel that streams information about detected
 * security threats to Flutter.
 */
internal object TalsecThreatHandler {
    private var eventSink: EventSink? = null
    private var methodSink: MethodCallHandler.MethodSink? = null
    private var isListening = false

    /**
     * Initializes [Talsec] and starts the [PluginThreatHandler] listener with this object.
     *
     * @param context The Android application context.
     */
    internal fun start(context: Context, config: TalsecConfig) {
        attachListener(context)
        Talsec.start(context, config)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ScreenProtector.enable()
        }
    }

    /**
     * Unregisters the threat handler and stops Talsec.
     *
     * @param context The Android application context.
     */
    internal fun stop(context: Context) {
        detachListener(context)
        PluginThreatHandler.listener = null
        Talsec.stop()
    }

    /**
     * Detaches the listener if the listener is currently
     * attached.
     *
     * @param context The context of the application.
     */
    internal fun detachListener(context: Context) {
        if (!isListening) {
            return
        }

        isListening = false
        PluginThreatHandler.unregisterListener(context)
    }

    /**
     * Attaches listener with given [context]. Only one listener can be registered at a time.
     * If multiple listeners try to attach, they will be ignored. To register a new listener, you
     * must first call [detachListener].
     *
     * This prevents double registration of the listener on startup: [start] function is called
     * from the native side, which registers the listener. After startup, onResume lifecycle is also
     * invoked, which is ignored.
     *
     * @param context The Android application context.
     */
    internal fun attachListener(context: Context) {
        if (isListening) {
            // If called on multiple times, keep old listener.
            // This prevents multiple listeners listening when going from background.
            return
        }

        PluginThreatHandler.registerListener(context)
        isListening = true
    }

    /**
     * Suspends the threat listener.
     *
     * In contrast to [detachListener], this function does not unregister the listener. It only
     * suspends the listener, meaning all detected threats are cached and sent later.
     *
     * In contrast to [detachEventSink], this function does not nullify the [eventSink]. It only suspends
     * sending events to the event sink. This is useful when the application goes to background and
     * [EventSink] is not destroyed but also is not able to send events.
     */
    internal fun suspendListener() {
        PluginThreatHandler.listener = null
    }

    /**
     * Resumes the threat listener.
     *
     * In contrast to [attachListener], this function does not register the listener. It only
     * resumes the listener, meaning all cached threats are sent to the [EventSink].
     *
     * In contrast to [attachEventSink], this function does not assign new [EventSink] to [eventSink].
     * It only resumes sending events to the current [eventSink].
     * This is useful when the application comes to foreground and [EventSink] is not destroyed but
     * also is not able to send events.
     */
    internal fun resumeListener() {
        eventSink?.let {
            PluginThreatHandler.listener = ThreatListener
            flushThreatCache(it)
        }
    }

    /**
     * Called when a new listener subscribes to the event channel. Sends any previously detected
     * threats to the new listener.
     *
     * @param eventSink The event sink of the new listener.
     */
    internal fun attachEventSink(eventSink: EventSink) {
        this.eventSink = eventSink
        PluginThreatHandler.listener = ThreatListener
        flushThreatCache(eventSink)
    }

    /**
     * Called when a listener unsubscribes from the event channel.
     */
    internal fun detachEventSink() {
        eventSink = null
        PluginThreatHandler.listener = null
    }

    /**
     * Sends any cached detected threats to the listener.
     *
     * @param eventSink The event sink of the new listener.
     */
    private fun flushThreatCache(eventSink: EventSink?) {
        PluginThreatHandler.detectedThreats.forEach {
            eventSink?.success(it.value)
        }

        PluginThreatHandler.detectedMalware.let {
            if (it.isNotEmpty()) {
                methodSink?.onMalwareDetected(it)
            }
        }

        PluginThreatHandler.detectedThreats.clear()
        PluginThreatHandler.detectedMalware.clear()
    }

    internal fun attachMethodSink(sink: MethodCallHandler.MethodSink) {
        this.methodSink = sink
    }

    internal fun detachMethodSink() {
        methodSink = null
    }

    /**
     * Called when a security threat is detected. Sends the threat information to the current
     * listener (if one exists) or adds it to the [PluginThreatHandler.detectedThreats] list to be
     * sent to the next listener that subscribes to the event channel.
     */
    internal object ThreatListener : PluginThreatHandler.TalsecFlutter {
        override fun threatDetected(threatType: Threat) {
            eventSink?.success(threatType.value)
        }

        override fun malwareDetected(suspiciousApps: List<SuspiciousAppInfo>) {
            methodSink?.onMalwareDetected(suspiciousApps)
        }
    }
}

