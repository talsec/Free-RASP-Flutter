package com.aheaditec.freerasp

internal enum class Threat(val value: String) {
    DEBUG("debug"),
    HOOKS("hooks"),
    PASSCODE("passcode"),
    SIMULATOR("simulator"),
    APP_INTEGRITY("appIntegrity"),
    OBFUSCATION_ISSUES("obfuscationIssues"),
    DEVICE_BINDING("deviceBinding"),
    UNOFFICIAL_STORE("unofficialStore"),
    PRIVILEGED_ACCESS("privilegedAccess"),
    SECURE_HARDWARE_NOT_AVAILABLE("secureHardwareNotAvailable"),
}