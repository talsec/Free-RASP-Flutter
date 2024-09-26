package com.aheaditec.freerasp.models

import com.aheaditec.talsec_security.security.api.SuspiciousAppInfo as TalsecSuspiciousAppInfo

class SuspiciousAppInfo(
    val packageInfo: PackageInfo,
    val reason: String
) {
    companion object {
        fun fromTalsec(suspiciousAppInfo: TalsecSuspiciousAppInfo): SuspiciousAppInfo {
            return SuspiciousAppInfo(
                PackageInfo.fromTalsec(suspiciousAppInfo.packageInfo),
                suspiciousAppInfo.reason
            )
        }
    }

    fun toJson(): String {
        return "{\"packageInfo\": ${packageInfo.toJson()}, \"reason\": \"$reason\"}"
    }
}