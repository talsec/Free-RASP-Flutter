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
        // Implementation note: The dispatcher logic handles flushing on set. 
        // But here we need to restore the previous sink if we stored it? 
        // Or does the StreamHandler re-attach it?
        // StreamHandler doesn't seem to detach on pause.
        // However, the original code set PluginThreatHandler.listener = null on suspend.
        // And reset it on resume.
        // With Dispatcher, setting sink to null effectively 'suspends' (caches) events.
        // But we need to save the sink to restore it.
        // Actually, StreamHandler manages the connection. 
        // If the activity pauses, does StreamHandler detach? No.
        // But we might want to stop sending events to Flutter when backgrounded?
        // The original code: suspendListener -> PluginThreatHandler.listener = null
        // resumeListener -> PluginThreatHandler.listener = ThreatListener (and flush)
        
        // In Dispatcher pattern:
        // We can just set sink to null. But where do we get it back from?
        // We need to store it temporarily?
        // Or relies on StreamHandler re-attaching?
        // StreamHandler.onCancel is called when stream is cancelled (e.g. Flutter side cancels).
        // It's not called on Activity pause.
        
        // For now, I will assume the StreamHandler/MethodHandler keeps the reference.
        // But if I set dispatcher.sink = null, I lose it.
        // I should probably not set it to null if I want to keep it?
        // But the requirement is to cache events while backgrounded.
        // So I need to set sink to null in dispatcher.
        // AND I need to save it here in TalsecThreatHandler to restore it.
    }
    
    // Let's refine suspend/resume.
    private var savedEventSink: EventSink? = null
    
    internal fun suspendListener() {
         savedEventSink = threatDispatcher.eventSink
         threatDispatcher.eventSink = null
    }
    
    internal fun resumeListener() {
        if (savedEventSink != null) {
            threatDispatcher.eventSink = savedEventSink
            savedEventSink = null
        }
    }

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


