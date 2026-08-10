package com.aheaditec.freerasp.handlers

import android.content.Context
import com.aheaditec.freerasp.RaspExecutionStateEvent
import com.aheaditec.freerasp.Threat
import com.aheaditec.freerasp.dispatchers.ExecutionStateDispatcher
import com.aheaditec.freerasp.dispatchers.ThreatDispatcher
import app.talsec.rasp.security.api.SuspiciousAppInfo
import app.talsec.rasp.security.api.ThreatListener
import app.talsec.rasp.security.api.ThreatListener.DeviceState
import app.talsec.rasp.security.api.ThreatListener.RaspExecutionState
import app.talsec.rasp.security.api.ThreatListener.ThreatDetected

/**
 * A Singleton object that manages the [ThreatListener] to handle detected security threats in the application.
 * The object provides methods to register a listener for threat notifications and notifies the
 * listener when a security threat is detected.
 */
internal object PluginThreatHandler {

    private val threatDetected = object : ThreatDetected() {
        override fun onPrivilegedAccess() {
            ThreatDispatcher.dispatchThreat(Threat.PrivilegedAccess)
        }

        override fun onDebug() {
            ThreatDispatcher.dispatchThreat(Threat.Debug)
        }

        override fun onSimulator() {
            ThreatDispatcher.dispatchThreat(Threat.Simulator)
        }

        override fun onAppIntegrity() {
            ThreatDispatcher.dispatchThreat(Threat.AppIntegrity)
        }

        override fun onUnofficialStore() {
            ThreatDispatcher.dispatchThreat(Threat.UnofficialStore)
        }

        override fun onHooks() {
            ThreatDispatcher.dispatchThreat(Threat.Hooks)
        }

        override fun onDeviceBinding() {
            ThreatDispatcher.dispatchThreat(Threat.DeviceBinding)
        }

        override fun onObfuscationIssues() {
            ThreatDispatcher.dispatchThreat(Threat.ObfuscationIssues)
        }

        override fun onMalware(suspiciousApps: List<SuspiciousAppInfo>) {
            ThreatDispatcher.dispatchMalware(suspiciousApps)
        }

        override fun onScreenshot() {
            ThreatDispatcher.dispatchThreat(Threat.Screenshot)
        }

        override fun onScreenRecording() {
            ThreatDispatcher.dispatchThreat(Threat.ScreenRecording)
        }

        override fun onMultiInstance() {
            ThreatDispatcher.dispatchThreat(Threat.MultiInstance)
        }

        override fun onUnsecureWifi() {
            ThreatDispatcher.dispatchThreat(Threat.UnsecureWiFi)
        }

        override fun onTimeSpoofing() {
            ThreatDispatcher.dispatchThreat(Threat.TimeSpoofing)
        }

        override fun onLocationSpoofing() {
            ThreatDispatcher.dispatchThreat(Threat.LocationSpoofing)
        }

        override fun onAutomation() {
            ThreatDispatcher.dispatchThreat(Threat.Automation)
        }

        override fun onBootloader() {
            ThreatDispatcher.dispatchThreat(Threat.Bootloader)
        }
    }

    private val deviceState = object : DeviceState() {
        override fun onPasscode() {
            ThreatDispatcher.dispatchThreat(Threat.Passcode)
        }

        override fun onSecureHardwareNotAvailable() {
            ThreatDispatcher.dispatchThreat(Threat.SecureHardwareNotAvailable)
        }

        override fun onSystemVpn() {
            ThreatDispatcher.dispatchThreat(Threat.SystemVPN)
        }

        override fun onDevMode() {
            ThreatDispatcher.dispatchThreat(Threat.DevMode)
        }

        override fun onAdbEnabled() {
            ThreatDispatcher.dispatchThreat(Threat.ADBEnabled)
        }
    }

    private val raspExecutionState = object : RaspExecutionState() {
        override fun onAllChecksFinished() {
            ExecutionStateDispatcher.dispatch(RaspExecutionStateEvent.AllChecksFinished)
        }
    }

    private val internalListener = ThreatListener(threatDetected, deviceState, raspExecutionState)

    internal fun registerListener(context: Context) {
        internalListener.registerListener(context)
    }

    internal fun unregisterListener(context: Context) {
        internalListener.unregisterListener(context)
    }
}
