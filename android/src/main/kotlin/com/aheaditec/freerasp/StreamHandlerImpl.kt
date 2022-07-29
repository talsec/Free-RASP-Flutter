package com.aheaditec.freerasp

import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler

class StreamHandlerImpl : StreamHandler {

    var talsecApp: TalsecApp? = null
    private var eventChannel: EventChannel? = null

    companion object {
        private const val CHANNEL_NAME: String = "plugins.aheaditec.com/events"
    }

    fun createEventChannel(messenger: BinaryMessenger) {
        if (eventChannel != null) {
            Log.w(
                "StreamHandler",
                "Tried to set method handler when last instance was not destroyed."
            )
            destroyEventChannel()
        }
        eventChannel = EventChannel(messenger, CHANNEL_NAME).also {
            it.setStreamHandler(this)
        }
    }

    fun destroyEventChannel() {
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        talsecApp?.let {
            it.events = events
        } ?: Log.w(
            "StreamHandler",
            "Tried to listen on EventChannel when Talsec was not initialized."
        )
    }

    override fun onCancel(arguments: Any?) {
        talsecApp?.events = null
    }
}