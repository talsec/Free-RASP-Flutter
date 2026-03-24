package com.aheaditec.freerasp.dispatchers

import com.aheaditec.freerasp.RaspExecutionStateEvent
import io.flutter.plugin.common.EventChannel.EventSink

internal object ExecutionStateDispatcher {
    private val eventCache = mutableSetOf<RaspExecutionStateEvent>()
    private var isAppInForeground = false

    var eventSink: EventSink? = null
        set(value) {
            field = value
            if (value != null) {
                isAppInForeground = true
                flushCache()
            }
        }

    fun onResume() {
        isAppInForeground = true
        if (eventSink != null) {
            flushCache()
        }
    }

    fun onPause() {
        isAppInForeground = false
    }

    fun dispatch(event: RaspExecutionStateEvent) {
        // We can only use the sink if the app is in foreground and the sink is not null
        // We don't need to check for isListenerRegistered because it is equivalent to eventSink != null
        if (isAppInForeground && eventSink != null) {
            eventSink?.success(event.value)
        } else {
            synchronized(eventCache) {
                eventCache.add(event)
            }
        }
    }

    private fun flushCache() {
        val events = synchronized(eventCache) {
            val snapshot = eventCache.toSet()
            eventCache.clear()
            snapshot
        }
        events.forEach { eventSink?.success(it.value) }
    }
}
