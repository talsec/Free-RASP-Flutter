package com.aheaditec.freerasp.handlers

import android.content.Context
import com.aheaditec.freerasp.RaspExecutionStateEvent
import com.aheaditec.freerasp.Threat
import com.aheaditec.freerasp.dispatchers.ExecutionStateDispatcher
import com.aheaditec.freerasp.dispatchers.ThreatDispatcher
import com.aheaditec.talsec_security.security.api.SuspiciousAppInfo
import com.aheaditec.talsec_security.security.api.ThreatListener
import com.aheaditec.talsec_security.security.api.ThreatListener.DeviceState
import com.aheaditec.talsec_security.security.api.ThreatListener.RaspExecutionState
import com.aheaditec.talsec_security.security.api.ThreatListener.ThreatDetected

/**
 * A Singleton object that manages the [ThreatListener] to handle detected security threats in the application.
 * The object provides methods to register a listener for threat notifications and notifies the
 * listener when a security threat is detected.
 */
internal object PluginThreatHandler {

    private val threatDetected = object : ThreatDetected() {
        override fun onRootDetected() {
            ThreatDispatcher.dispatchThreat(Threat.PrivilegedAccess)
        }

        override fun onDebuggerDetected() {
            ThreatDispatcher.dispatchThreat(Threat.Debug)
        }

        override fun onEmulatorDetected() {
            ThreatDispatcher.dispatchThreat(Threat.Simulator)
        }

        override fun onTamperDetected() {
            ThreatDispatcher.dispatchThreat(Threat.AppIntegrity)
        }

        override fun onUntrustedInstallationSourceDetected() {
            ThreatDispatcher.dispatchThreat(Threat.UnofficialStore)
        }

        override fun onHookDetected() {
            ThreatDispatcher.dispatchThreat(Threat.Hooks)
        }

        override fun onDeviceBindingDetected() {
            ThreatDispatcher.dispatchThreat(Threat.DeviceBinding)
        }

        override fun onObfuscationIssuesDetected() {
            ThreatDispatcher.dispatchThreat(Threat.ObfuscationIssues)
        }

        override fun onMalwareDetected(suspiciousApps: List<SuspiciousAppInfo>) {
            ThreatDispatcher.dispatchMalware(suspiciousApps)
        }

        override fun onScreenshotDetected() {
            ThreatDispatcher.dispatchThreat(Threat.Screenshot)
        }

        override fun onScreenRecordingDetected() {
            ThreatDispatcher.dispatchThreat(Threat.ScreenRecording)
        }

        override fun onMultiInstanceDetected() {
            ThreatDispatcher.dispatchThreat(Threat.MultiInstance)
        }

        override fun onUnsecureWifiDetected() {
            ThreatDispatcher.dispatchThreat(Threat.UnsecureWiFi)
        }

        override fun onTimeSpoofingDetected() {
            ThreatDispatcher.dispatchThreat(Threat.TimeSpoofing)
        }

        override fun onLocationSpoofingDetected() {
            ThreatDispatcher.dispatchThreat(Threat.LocationSpoofing)
        }

        override fun onAutomationDetected() {
            ThreatDispatcher.dispatchThreat(Threat.Automation)
        }
    }

    private val deviceState = object : DeviceState() {
        override fun onUnlockedDeviceDetected() {
            ThreatDispatcher.dispatchThreat(Threat.Passcode)
        }

        override fun onHardwareBackedKeystoreNotAvailableDetected() {
            ThreatDispatcher.dispatchThreat(Threat.SecureHardwareNotAvailable)
        }

        override fun onSystemVPNDetected() {
            ThreatDispatcher.dispatchThreat(Threat.SystemVPN)
        }

        override fun onDeveloperModeDetected() {
            ThreatDispatcher.dispatchThreat(Threat.DevMode)
        }

        override fun onADBEnabledDetected() {
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