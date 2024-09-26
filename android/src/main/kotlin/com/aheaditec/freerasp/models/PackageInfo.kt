package com.aheaditec.freerasp.models

import org.json.JSONObject

data class PackageInfo(
    val packageName: String,
    val appIcon: String? = null,
    val appName: String? = null,
    val version: String? = null,
    val installationSource: String? = null
) {
    companion object {
        fun fromTalsec(packageInfo: android.content.pm.PackageInfo): PackageInfo {
            return PackageInfo(
                packageInfo.packageName,
                packageInfo.appIcon,
                packageInfo.appName,
                packageInfo.version,
                packageInfo.installationSource
            )
        }
    }

    fun toJson(): String {
        val json = JSONObject().put("packageName", packageName)
            .putOpt("appIcon", appIcon)
            .putOpt("appName", appName)
            .putOpt("version", version)
            .putOpt("installationSource", installationSource)

        return json.toString()
    }
}