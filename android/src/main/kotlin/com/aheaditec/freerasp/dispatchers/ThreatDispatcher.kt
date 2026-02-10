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
        val currentSink = eventSink
        if (currentSink != null) {
            currentSink.success(threat.value)
        } else {
            synchronized(threatCache) {
                val checkedSink = eventSink
                checkedSink?.success(threat.value) ?: threatCache.add(threat)
            }
        }
    }

    fun dispatchMalware(apps: List<SuspiciousAppInfo>) {
        val currentSink = methodSink
        if (currentSink != null) {
            currentSink.onMalwareDetected(apps)
        } else {
            synchronized(malwareCache) {
                val checkedSink = methodSink
                checkedSink?.onMalwareDetected(apps) ?: malwareCache.addAll(apps)
            }
        }
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
