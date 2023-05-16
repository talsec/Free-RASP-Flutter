package com.aheaditec.freerasp.handlers

import android.content.Context
import com.aheaditec.freerasp.Threat
import com.aheaditec.talsec_security.security.api.ThreatListener
import com.aheaditec.talsec_security.security.api.ThreatListener.DeviceState
import com.aheaditec.talsec_security.security.api.ThreatListener.ThreatDetected

/**
 * A Singleton object that implements the [ThreatDetected] and [DeviceState] interfaces to handle
 * detected security threats in the application.
 * The object provides methods to register a listener for threat notifications and notifies the
 * listener when a security threat is detected.
 */
internal object PluginThreatHandler : ThreatDetected, DeviceState {
    internal val detectedThreats = mutableSetOf<Threat>()
    internal var listener: TalsecFlutter? = null
    private val internalListener = ThreatListener(this, this)

    internal fun registerListener(context: Context) {
        internalListener.registerListener(context)
    }

    internal fun unregisterListener(context: Context) {
        internalListener.unregisterListener(context)
    }

    override fun onRootDetected() {
        notify(Threat.PRIVILEGED_ACCESS)
    }

    override fun onDebuggerDetected() {
        notify(Threat.DEBUG)
    }

    override fun onEmulatorDetected() {
        notify(Threat.SIMULATOR)
    }

    override fun onTamperDetected() {
        notify(Threat.APP_INTEGRITY)
    }

    override fun onUntrustedInstallationSourceDetected() {
        notify(Threat.UNOFFICIAL_STORE)
    }

    override fun onHookDetected() {
        notify(Threat.HOOKS)
    }

    override fun onDeviceBindingDetected() {
        notify(Threat.DEVICE_BINDING)
    }

    override fun onUnlockedDeviceDetected() {
        notify(Threat.PASSCODE)
    }

    override fun onHardwareBackedKeystoreNotAvailableDetected() {
        notify(Threat.SECURE_HARDWARE_NOT_AVAILABLE)
    }

    private fun notify(threat: Threat) {
        listener?.threatDetected(threat) ?: detectedThreats.add(threat)
    }

    internal interface TalsecFlutter {
        fun threatDetected(threatType: Threat)
    }
}
