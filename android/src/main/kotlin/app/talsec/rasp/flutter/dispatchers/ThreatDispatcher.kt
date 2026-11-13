package app.talsec.rasp.flutter.dispatchers

import app.talsec.rasp.flutter.Threat
import app.talsec.rasp.flutter.toFlutterName
import app.talsec.rasp.security.api.ThreatListener.CallState
import io.flutter.plugin.common.EventChannel.EventSink

/**
 * Sends detections to Flutter over the threat [EventSink], in the order in which they occur.
 *
 * A plain threat is sent as its [Int] code. A detection with a payload is sent as a map with a
 * `type` key: `malware` (with `suspiciousApps`) or `ongoingCall` (with `state`). Detections that
 * occur while the app is in background or no listener is attached are cached and sent later.
 */
internal object ThreatDispatcher {
    private val threatCache = mutableSetOf<Threat>()
    private val malwareCache = mutableListOf<Map<String, Any?>>()
    private val callStateCache = mutableListOf<CallState>()
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

    fun dispatchThreat(threat: Threat) {
        if (isAppInForeground && eventSink != null) {
            eventSink?.success(threat.value)
        } else {
            synchronized(threatCache) {
                threatCache.add(threat)
            }
        }
    }

    /**
     * @param apps The suspicious apps, already converted with `toFlutterMap`.
     */
    fun dispatchMalware(apps: List<Map<String, Any?>>) {
        if (isAppInForeground && eventSink != null) {
            eventSink?.success(malwareEvent(apps))
        } else {
            synchronized(malwareCache) {
                malwareCache.addAll(apps)
            }
        }
    }

    fun dispatchOngoingCall(state: CallState) {
        if (isAppInForeground && eventSink != null) {
            eventSink?.success(ongoingCallEvent(state))
        } else {
            // Keep the order: a call that started and stopped in background is reported as both.
            synchronized(callStateCache) {
                callStateCache.add(state)
            }
        }
    }

    private fun flushCache() {
        flushThreatCache()
        flushMalwareCache()
        flushCallStateCache()
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
            val snapshot = malwareCache.toList()
            malwareCache.clear()
            snapshot
        }
        if (malware.isNotEmpty()) {
            eventSink?.success(malwareEvent(malware))
        }
    }

    private fun flushCallStateCache() {
        val states = synchronized(callStateCache) {
            val snapshot = callStateCache.toList()
            callStateCache.clear()
            snapshot
        }
        states.forEach { eventSink?.success(ongoingCallEvent(it)) }
    }

    private fun malwareEvent(apps: List<Map<String, Any?>>): Map<String, Any?> =
        mapOf("type" to "malware", "suspiciousApps" to apps)

    private fun ongoingCallEvent(state: CallState): Map<String, Any?> =
        mapOf("type" to "ongoingCall", "state" to state.toFlutterName())
}
