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

    internal val threatDispatcher = ThreatDispatcher()
    internal val executionStateDispatcher = ExecutionStateDispatcher()

    private val threatDetected = object : ThreatDetected() {
        override fun onRootDetected() {
            threatDispatcher.dispatchThreat(Threat.PrivilegedAccess)
        }

        override fun onDebuggerDetected() {
            threatDispatcher.dispatchThreat(Threat.Debug)
        }

        override fun onEmulatorDetected() {
            threatDispatcher.dispatchThreat(Threat.Simulator)
        }

        override fun onTamperDetected() {
            threatDispatcher.dispatchThreat(Threat.AppIntegrity)
        }

        override fun onUntrustedInstallationSourceDetected() {
            threatDispatcher.dispatchThreat(Threat.UnofficialStore)
        }

        override fun onHookDetected() {
            threatDispatcher.dispatchThreat(Threat.Hooks)
        }

        override fun onDeviceBindingDetected() {
            threatDispatcher.dispatchThreat(Threat.DeviceBinding)
        }

        override fun onObfuscationIssuesDetected() {
            threatDispatcher.dispatchThreat(Threat.ObfuscationIssues)
        }

        override fun onMalwareDetected(suspiciousApps: List<SuspiciousAppInfo>) {
            threatDispatcher.dispatchMalware(suspiciousApps)
        }

        override fun onScreenshotDetected() {
            threatDispatcher.dispatchThreat(Threat.Screenshot)
        }

        override fun onScreenRecordingDetected() {
            threatDispatcher.dispatchThreat(Threat.ScreenRecording)
        }

        override fun onMultiInstanceDetected() {
            threatDispatcher.dispatchThreat(Threat.MultiInstance)
        }

        override fun onUnsecureWifiDetected() {
            threatDispatcher.dispatchThreat(Threat.UnsecureWiFi)
        }

        override fun onTimeSpoofingDetected() {
            threatDispatcher.dispatchThreat(Threat.TimeSpoofing)
        }

        override fun onLocationSpoofingDetected() {
            threatDispatcher.dispatchThreat(Threat.LocationSpoofing)
        }

        override fun onAutomationDetected() {
            threatDispatcher.dispatchThreat(Threat.Automation)
        }
    }

    private val deviceState = object : DeviceState() {
        override fun onUnlockedDeviceDetected() {
            threatDispatcher.dispatchThreat(Threat.Passcode)
        }

        override fun onHardwareBackedKeystoreNotAvailableDetected() {
            threatDispatcher.dispatchThreat(Threat.SecureHardwareNotAvailable)
        }

        override fun onSystemVPNDetected() {
            threatDispatcher.dispatchThreat(Threat.SystemVPN)
        }

        override fun onDeveloperModeDetected() {
            threatDispatcher.dispatchThreat(Threat.DevMode)
        }

        override fun onADBEnabledDetected() {
            threatDispatcher.dispatchThreat(Threat.ADBEnabled)
        }
    }

    private val raspExecutionState = object : RaspExecutionState() {
        override fun onAllChecksFinished() {
            executionStateDispatcher.dispatch(RaspExecutionStateEvent.AllChecksFinished)
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