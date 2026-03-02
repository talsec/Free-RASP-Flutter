package com.aheaditec.freerasp.dispatchers

import com.aheaditec.freerasp.Threat
import com.aheaditec.freerasp.handlers.MethodCallHandler
import com.aheaditec.talsec_security.security.api.SuspiciousAppInfo
import io.flutter.plugin.common.EventChannel.EventSink

internal class ThreatDispatcher {
    private val threatCache = mutableSetOf<Threat>()
    private val malwareCache = mutableListOf<SuspiciousAppInfo>()
    private var isAppInForeground = false

    var eventSink: EventSink? = null
        set(value) {
            field = value
            if (value != null) {
                isAppInForeground = true
                flushThreatCache()
            }
        }

    var methodSink: MethodCallHandler.MethodSink? = null
        set(value) {
            field = value
            if (value != null) {
                isAppInForeground = true
                flushMalwareCache()
            }
        }

    fun onResume() {
        isAppInForeground = true
        if (eventSink != null) {
            flushThreatCache()
        }
        if (methodSink != null) {
            flushMalwareCache()
        }
    }

    fun onPause() {
        isAppInForeground = false
    }

    fun dispatchThreat(threat: Threat) {
        if (isAppInForeground && eventSink != null) {
            eventSink?.success(threat.value)
        } else {
            synchronized(threatCache) {
                threatCache.add(threat)
            }
        }
    }

    fun dispatchMalware(apps: List<SuspiciousAppInfo>) {
        if (isAppInForeground && methodSink != null) {
            methodSink?.onMalwareDetected(apps)
        } else {
            synchronized(malwareCache) {
                malwareCache.addAll(apps)
            }
        }
    }

    private fun flushThreatCache() {
        val threats = synchronized(threatCache) {
            val snapshot = threatCache.toSet()
            threatCache.clear()
            snapshot
        }
        threats.forEach { eventSink?.success(it.value) }
    }

    private fun flushMalwareCache() {
        val malware = synchronized(malwareCache) {
            val snapshot = malwareCache.toMutableList()
            malwareCache.clear()
            snapshot
        }
        if (malware.isNotEmpty()) {
            methodSink?.onMalwareDetected(malware)
        }
    }
}
