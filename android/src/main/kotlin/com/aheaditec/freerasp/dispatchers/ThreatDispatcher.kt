package com.aheaditec.freerasp.dispatchers

import com.aheaditec.freerasp.Threat
import com.aheaditec.freerasp.handlers.MethodCallHandler
import com.aheaditec.talsec_security.security.api.SuspiciousAppInfo
import io.flutter.plugin.common.EventChannel.EventSink

internal class ThreatDispatcher {
    private val threatCache = mutableSetOf<Threat>()
    private val malwareCache = mutableListOf<SuspiciousAppInfo>()

    var eventSink: EventSink? = null
        set(value) {
            field = value
            if (value != null) {
                flushThreatCache(value)
            }
        }

    var methodSink: MethodCallHandler.MethodSink? = null
        set(value) {
            field = value
            if (value != null) {
                flushMalwareCache(value)
            }
        }

    fun dispatchThreat(threat: Threat) {
        val sink = synchronized(threatCache) {
            val currentSink = eventSink
            if (currentSink != null) {
                currentSink
            } else {
                threatCache.add(threat)
                null
            }
        }
        sink?.success(threat.value)
    }

    fun dispatchMalware(apps: List<SuspiciousAppInfo>) {
        val sink = synchronized(malwareCache) {
            val currentSink = methodSink
            if (currentSink != null) {
                currentSink
            } else {
                malwareCache.addAll(apps)
                null
            }
        }
        sink?.onMalwareDetected(apps)
    }

    private fun flushThreatCache(sink: EventSink) {
        val threats = synchronized(threatCache) {
            val snapshot = threatCache.toSet()
            threatCache.clear()
            snapshot
        }
        threats.forEach { sink.success(it.value) }
    }

    private fun flushMalwareCache(sink: MethodCallHandler.MethodSink) {
        val malware = synchronized(malwareCache) {
            val snapshot = malwareCache.toMutableList()
            malwareCache.clear()
            snapshot
        }
        if (malware.isNotEmpty()) {
            sink.onMalwareDetected(malware)
        }
    }
}
