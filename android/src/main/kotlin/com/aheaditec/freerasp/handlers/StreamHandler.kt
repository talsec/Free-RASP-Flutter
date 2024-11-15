package com.aheaditec.freerasp.handlers

import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/**
 * A stream handler that creates and manages an [EventChannel] for freeRASP events.
 * The stream handler listens for new subscribers to the event channel and forwards
 * all incoming events to [TalsecThreatHandler] for processing.
 */
internal class StreamHandler : EventChannel.StreamHandler {

    private var eventChannel: EventChannel? = null

    companion object {
        private const val CHANNEL_NAME: String = "talsec.app/freerasp/events"
    }

    /**
     * Creates a [EventChannel] with the specified [BinaryMessenger] instance.
     * If an old [EventChannel] already exists, it will be destroyed before creating a new one.
     *
     * @param messenger The binary messenger to use for creating the [EventChannel].
     */
    internal fun createEventChannel(messenger: BinaryMessenger) {
        if (eventChannel != null) {
            Log.i("StreamCallHandler", "Tried to create channel without disposing old one.")
            destroyEventChannel()
        }
        eventChannel = EventChannel(messenger, CHANNEL_NAME).also {
            it.setStreamHandler(this)
        }
    }

    /**
     * Destroys the current event channel.
     */
    internal fun destroyEventChannel() {
        eventChannel?.setStreamHandler(null)
        eventChannel = null

        // Don't forget to remove old sink
        // @see https://stackoverflow.com/questions/61934900/tried-to-send-a-platform-message-to-flutter-but-flutterjni-was-detached-from-n
        TalsecThreatHandler.detachEventSink()
    }

    /**
     * Called when a new subscriber listens to the [EventChannel]. Forwards all incoming events
     * to [TalsecThreatHandler] for processing.
     *
     * @param arguments The arguments passed by the subscriber. Not used in this implementation.
     * @param events The event sink used for sending events to the subscriber.
     */
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        events?.let {
            TalsecThreatHandler.attachEventSink(it)
        }
    }

    /**
     * Called when a subscriber cancels their subscription to the event channel. Detaches the
     * event sink from [TalsecThreatHandler].
     *
     * @param arguments The arguments passed by the subscriber. Not used in this implementation.
     */
    override fun onCancel(arguments: Any?) {
        TalsecThreatHandler.detachEventSink()
    }
}