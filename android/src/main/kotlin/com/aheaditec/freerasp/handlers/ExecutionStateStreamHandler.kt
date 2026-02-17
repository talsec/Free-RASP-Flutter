package com.aheaditec.freerasp.handlers

import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/**
 * A stream handler that creates and manages an [EventChannel] for freeRASP execution state events.
 */
internal class ExecutionStateStreamHandler : EventChannel.StreamHandler {

    private var eventChannel: EventChannel? = null

    companion object {
        private const val CHANNEL_NAME: String = "talsec.app/freerasp/execution_state"
    }

    internal fun createEventChannel(messenger: BinaryMessenger) {
        if (eventChannel != null) {
            Log.i("ExecStateStreamHandler", "Tried to create channel without disposing old one.")
            destroyEventChannel()
        }
        eventChannel = EventChannel(messenger, CHANNEL_NAME).also {
            it.setStreamHandler(this)
        }
    }

    internal fun destroyEventChannel() {
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        TalsecThreatHandler.detachExecutionStateSink()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        events?.let {
            TalsecThreatHandler.attachExecutionStateSink(it)
        }
    }

    override fun onCancel(arguments: Any?) {
        TalsecThreatHandler.detachExecutionStateSink()
    }
}
