package com.aheaditec.freerasp.handlers

import android.content.Context
import com.aheaditec.freerasp.Threat
import com.aheaditec.talsec_security.security.api.Talsec
import com.aheaditec.talsec_security.security.api.TalsecConfig
import io.flutter.plugin.common.EventChannel

/**
 * Object responsible for managing the event channel that streams information about detected
 * security threats to Flutter.
 */
internal object TalsecThreatHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var isListening = false

    /**
     * Initializes [Talsec] and starts the [PluginThreatHandler] listener with this object.
     *
     * @param context The Android application context.
     */
    internal fun start(context : Context, config: TalsecConfig) {
        attachListener(context)
        Talsec.start(context, config)
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
     * Called when a new listener subscribes to the event channel. Sends any previously detected
     * threats to the new listener.
     *
     * @param eventSink The event sink of the new listener.
     */
    internal fun attachSink(eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
        PluginThreatHandler.listener = ThreatListener
        PluginThreatHandler.detectedThreats.forEach {
            eventSink.success(it.value)
        }
        PluginThreatHandler.detectedThreats.clear()
    }

    /**
     * Called when a listener unsubscribes from the event channel.
     */
    internal fun detachSink() {
        eventSink = null
        PluginThreatHandler.listener = null
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
    }
}
