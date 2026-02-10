package com.aheaditec.freerasp.dispatchers

import com.aheaditec.freerasp.RaspExecutionStateEvent
import io.flutter.plugin.common.EventChannel.EventSink

internal class ExecutionStateDispatcher {
    private val eventCache = mutableSetOf<RaspExecutionStateEvent>()

    var eventSink: EventSink? = null
        set(value) {
            field = value
            if (value != null) {
                flushCache(value)
            }
        }

    fun dispatch(event: RaspExecutionStateEvent) {
        val currentSink = eventSink
        if (currentSink != null) {
            sendToSink(currentSink, event)
        } else {
            synchronized(eventCache) {
                val checkedSink = eventSink
                if (checkedSink != null) {
                    sendToSink(checkedSink, event)
                } else {
                    eventCache.add(event)
                }
            }
        }
    }

    private fun flushCache(sink: EventSink) {
        val events = synchronized(eventCache) {
            val snapshot = eventCache.toSet()
            eventCache.clear()
            snapshot
        }
        events.forEach { sendToSink(sink, it) }
    }

    private fun sendToSink(sink: EventSink, event: RaspExecutionStateEvent) {
        when (event) {
            is RaspExecutionStateEvent.AllChecksFinished -> sink.success(event.value)
        }
    }
}
