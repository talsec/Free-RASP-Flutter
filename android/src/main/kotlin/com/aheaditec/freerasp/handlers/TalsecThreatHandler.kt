package com.aheaditec.freerasp.handlers

import android.content.Context
import android.os.Build
import com.aheaditec.freerasp.RaspExecutionStateEvent
import com.aheaditec.freerasp.ScreenProtector
import com.aheaditec.freerasp.dispatchers.ExecutionStateDispatcher
import com.aheaditec.freerasp.dispatchers.ThreatDispatcher
import com.aheaditec.talsec_security.security.api.Talsec
import com.aheaditec.talsec_security.security.api.TalsecConfig
import io.flutter.plugin.common.EventChannel.EventSink

/**
 * Object responsible for managing the event channel that streams information about detected
 * security threats to Flutter.
 */
internal object TalsecThreatHandler {
    internal val threatDispatcher = ThreatDispatcher()
    internal val executionStateDispatcher = ExecutionStateDispatcher()
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
        savedEventSink = threatDispatcher.eventSink
        threatDispatcher.eventSink = null
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
        if (savedEventSink != null) {
            threatDispatcher.eventSink = savedEventSink
            savedEventSink = null
        }
    }
    
    // Let's refine suspend/resume.
    private var savedEventSink: EventSink? = null
    

    


    /**
     * Called when a new listener subscribes to the event channel. Sends any previously detected
     * threats to the new listener.
     *
     * @param eventSink The event sink of the new listener.
     */
    internal fun attachEventSink(eventSink: EventSink) {
        threatDispatcher.eventSink = eventSink
    }

    /**
     * Called when a listener unsubscribes from the event channel.
     */
    internal fun detachEventSink() {
        threatDispatcher.eventSink = null
        savedEventSink = null
    }

    internal fun attachExecutionStateSink(eventSink: EventSink) {
        executionStateDispatcher.eventSink = eventSink
    }

    internal fun detachExecutionStateSink() {
        executionStateDispatcher.eventSink = null
    }

    internal fun attachMethodSink(sink: MethodCallHandler.MethodSink) {
        threatDispatcher.methodSink = sink
    }

    internal fun detachMethodSink() {
        threatDispatcher.methodSink = null
    }
}


