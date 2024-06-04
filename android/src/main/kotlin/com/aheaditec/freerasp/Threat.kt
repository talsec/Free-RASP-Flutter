package com.aheaditec.freerasp

/**
 * Sealed class to represent the error codes.
 *
 * Sealed classes are used because of obfuscation - enums classes are not obfuscated well enough.
 *
 * @property value integer value of the error code.
 */
internal sealed class Threat(val value: Int) {
    object Debug : Threat(1268968002)

    object Hooks : Threat(209533833)

    object Passcode : Threat(1293399086)

    object Simulator : Threat(477190884)

    object AppIntegrity : Threat(1115787534)

    object ObfuscationIssues : Threat(1001443554)

    object DeviceBinding : Threat(1806586319)

    object UnofficialStore : Threat(629780916)

    object PrivilegedAccess : Threat(44506749)

    object SecureHardwareNotAvailable : Threat(1564314755)

    object SystemVPN : Threat(659382561)

    object DevMode : Threat(45291047)
}