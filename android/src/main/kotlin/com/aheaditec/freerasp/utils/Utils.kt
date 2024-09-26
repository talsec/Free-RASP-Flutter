package com.aheaditec.freerasp.utils

import com.aheaditec.talsec_security.security.api.SuspiciousAppInfo
import com.aheaditec.talsec_security.security.api.TalsecConfig
import org.json.JSONException
import org.json.JSONObject

internal class Utils {
    companion object {
        fun toTalsecConfigThrowing(configJson: String?): TalsecConfig {
            if (configJson == null) {
                throw JSONException("Configuration is null")
            }
            val json = JSONObject(configJson)

            val watcherMail = json.getString("watcherMail")
            var isProd = true
            if (json.has("isProd")) {
                isProd = json.getBoolean("isProd")
            }
            val androidConfig = json.getJSONObject("androidConfig")

            val packageName = androidConfig.getString("packageName")
            val certificateHashes = androidConfig.extractArray<String>("signingCertHashes")
            val alternativeStores = androidConfig.extractArray<String>("supportedStores")
            val blocklistedPackageNames =
                androidConfig.extractArray<String>("blocklistedPackageNames")
            val blocklistedHashes = androidConfig.extractArray<String>("blocklistedHashes")
            val whitelistedInstallationSources =
                androidConfig.extractArray<String>("whitelistedInstallationSources")

            val blocklistedPermissions = mutableListOf<Array<String>>()
            if (androidConfig.has("blocklistedPermissions")) {
                val permissions = androidConfig.getJSONArray("blocklistedPermissions")
                for (i in 0 until permissions.length()) {
                    val permission = permissions.getJSONArray(i)
                    val permissionList = mutableListOf<String>()
                    for (j in 0 until permission.length()) {
                        permissionList.add(permission.getString(j))
                    }
                    blocklistedPermissions.add(permissionList.toTypedArray())
                }
            }

            return TalsecConfig.Builder(packageName, certificateHashes)
                .watcherMail(watcherMail)
                .supportedAlternativeStores(alternativeStores)
                .prod(isProd)
                .blocklistedPackageNames(blocklistedPackageNames)
                .blocklistedHashes(blocklistedHashes)
                .blocklistedPermissions(blocklistedPermissions.toTypedArray())
                .whitelistedInstallationSources(whitelistedInstallationSources)
                .build()
        }

        fun fromTalsec(malwareInfo: List<SuspiciousAppInfo>) {
            val packageInfoList = mutableListOf<String>()
            for (info in malwareInfo) {
                packageInfoList.add(info.toJson())
            }
        }
    }
}

inline fun <reified T> JSONObject.extractArray(key: String): Array<T> {
    val list = mutableListOf<T>()
    if (this.has(key)) {
        val jsonArray = this.getJSONArray(key)
        for (i in 0 until jsonArray.length()) {
            val element = when (T::class) {
                String::class -> jsonArray.getString(i) as T
                Int::class -> jsonArray.getInt(i) as T
                Double::class -> jsonArray.getDouble(i) as T
                Boolean::class -> jsonArray.getBoolean(i) as T
                Long::class -> jsonArray.getLong(i) as T
                else -> throw IllegalArgumentException("Unsupported type")
            }
            list.add(element)
        }
    }
    return list.toTypedArray()
}
