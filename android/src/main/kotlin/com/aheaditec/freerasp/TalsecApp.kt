package com.aheaditec.freerasp

import android.content.Context
import com.aheaditec.talsec_security.security.api.Talsec
import com.aheaditec.talsec_security.security.api.TalsecConfig
import com.aheaditec.talsec_security.security.api.ThreatListener
import io.flutter.Log
import io.flutter.plugin.common.EventChannel

class TalsecApp(private val context: Context) : ThreatListener.ThreatDetected {

    var events: EventChannel.EventSink? = null

    fun init(
        packageName: String,
        signingHash: String,
        watcherMail: String,
        alternativeStores: Array<String>
    ) {
        val config = TalsecConfig(
            packageName,
            signingHash,
            watcherMail,
            alternativeStores
        )
        ThreatListener(this).registerListener(context)
        Talsec.start(context, config)
    }

    private fun submitEvent(threat: String) {
        events?.success(threat)
    }

    override fun onRootDetected() {
        Log.e("Threat","ROOT")
        submitEvent("onRootDetected")
    }

    override fun onDebuggerDetected() {
        submitEvent("onDebuggerDetected")
    }

    override fun onEmulatorDetected() {
        submitEvent("onEmulatorDetected")
    }

    override fun onTamperDetected() {
        submitEvent("onTamperDetected")
    }

    override fun onHookDetected() {
        submitEvent("onHookDetected")
    }

    override fun onDeviceBindingDetected() {
        submitEvent("onDeviceBindingDetected")
    }

    override fun onUntrustedInstallationSourceDetected() {
        submitEvent("onUntrustedInstallationSourceDetected")
    }
}