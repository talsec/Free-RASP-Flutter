package com.aheaditec.freerasp.handlers

import android.content.Context
import com.aheaditec.freerasp.RaspExecutionStateEvent
import com.aheaditec.freerasp.Threat
import com.aheaditec.talsec_security.security.api.SuspiciousAppInfo
import com.aheaditec.talsec_security.security.api.ThreatListener
import com.aheaditec.talsec_security.security.api.ThreatListener.DeviceState
import com.aheaditec.talsec_security.security.api.ThreatListener.RaspExecutionState
import com.aheaditec.talsec_security.security.api.ThreatListener.ThreatDetected

/**
 * A Singleton object that implements the [ThreatDetected] and [DeviceState] interfaces to handle
 * detected security threats in the application.
 * The object provides methods to register a listener for threat notifications and notifies the
 * listener when a security threat is detected.
 */
internal object PluginThreatHandler : ThreatDetected, DeviceState, RaspExecutionState() {

    private val internalListener = ThreatListener(this, this, this)

    internal fun registerListener(context: Context) {
        internalListener.registerListener(context)
    }

    internal fun unregisterListener(context: Context) {
        internalListener.unregisterListener(context)
    }

    override fun onAllChecksFinished() {
        TalsecThreatHandler.executionStateDispatcher.dispatch(RaspExecutionStateEvent.AllChecksFinished)
    }

    override fun onRootDetected() {
        notify(Threat.PrivilegedAccess)
    }

    override fun onDebuggerDetected() {
        notify(Threat.Debug)
    }

    override fun onEmulatorDetected() {
        notify(Threat.Simulator)
    }

    override fun onTamperDetected() {
        notify(Threat.AppIntegrity)
    }

    override fun onUntrustedInstallationSourceDetected() {
        notify(Threat.UnofficialStore)
    }

    override fun onHookDetected() {
        notify(Threat.Hooks)
    }

    override fun onDeviceBindingDetected() {
        notify(Threat.DeviceBinding)
    }

    override fun onObfuscationIssuesDetected() {
        notify(Threat.ObfuscationIssues)
    }

    override fun onUnlockedDeviceDetected() {
        notify(Threat.Passcode)
    }

    override fun onHardwareBackedKeystoreNotAvailableDetected() {
        notify(Threat.SecureHardwareNotAvailable)
    }

    override fun onSystemVPNDetected() {
        notify(Threat.SystemVPN)
    }

    override fun onDeveloperModeDetected() {
        notify(Threat.DevMode)
    }

    override fun onADBEnabledDetected() {
        notify(Threat.ADBEnabled)
    }

    override fun onScreenshotDetected() {
        notify(Threat.Screenshot)
    }

    override fun onScreenRecordingDetected() {
        notify(Threat.ScreenRecording)
    }

    override fun onMalwareDetected(suspiciousApps: List<SuspiciousAppInfo>) {
        notify(suspiciousApps)
    }

    override fun onMultiInstanceDetected() {
        notify(Threat.MultiInstance)
    }

    override fun onUnsecureWifiDetected() {
        notify(Threat.UnsecureWiFi)
    }

    override fun onTimeSpoofingDetected() {
        notify(Threat.TimeSpoofing)
    }

    override fun onLocationSpoofingDetected() {
        notify(Threat.LocationSpoofing)
    }

    override fun onAutomationDetected() {
        notify(Threat.Automation)
    }

    private fun notify(threat: Threat) {
        TalsecThreatHandler.threatDispatcher.dispatchThreat(threat)
    }

    private fun notify(suspiciousApps: List<SuspiciousAppInfo>) {
        TalsecThreatHandler.threatDispatcher.dispatchMalware(suspiciousApps)
    }
}
