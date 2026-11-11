package app.talsec.rasp.flutter.dispatchers

import app.talsec.rasp.flutter.Threat
import app.talsec.rasp.flutter.handlers.MethodCallHandler
import app.talsec.rasp.security.api.SuspiciousAppInfo
import app.talsec.rasp.security.api.ThreatListener.CallState
import io.flutter.plugin.common.EventChannel.EventSink

internal object ThreatDispatcher {
    private val threatCache = mutableSetOf<Threat>()
    private val malwareCache = mutableListOf<SuspiciousAppInfo>()
    private val callStateCache = mutableListOf<CallState>()
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
                flushCallStateCache()
            }
        }

    fun onResume() {
        isAppInForeground = true
        if (eventSink != null) {
            flushThreatCache()
        }
        if (methodSink != null) {
            flushMalwareCache()
            flushCallStateCache()
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

    fun dispatchOngoingCall(state: CallState) {
        if (isAppInForeground && methodSink != null) {
            methodSink?.onOngoingCall(state)
        } else {
            // Keep the order: a call that started and stopped in background is reported as both.
            synchronized(callStateCache) {
                callStateCache.add(state)
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

    private fun flushCallStateCache() {
        val states = synchronized(callStateCache) {
            val snapshot = callStateCache.toList()
            callStateCache.clear()
            snapshot
        }
        states.forEach { methodSink?.onOngoingCall(it) }
    }
}
