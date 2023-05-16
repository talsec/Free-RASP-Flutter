package com.aheaditec.freerasp.utils

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
            val androidConfig = json.getJSONObject("androidConfig")
            val packageName = androidConfig.getString("packageName")
            val certificateHashes = mutableListOf<String>()
            val hashes = androidConfig.getJSONArray("signingCertHashes")
            for (i in 0 until hashes.length()) {
                certificateHashes.add(hashes.getString(i))
            }
            val watcherMail = json.getString("watcherMail")
            val alternativeStores = mutableListOf<String>()
            if (androidConfig.has("supportedStores")) {
                val stores = androidConfig.getJSONArray("supportedStores")
                for (i in 0 until stores.length()) {
                    alternativeStores.add(stores.getString(i))
                }
            }
            var isProd = true
            if (json.has("isProd")) {
                isProd = json.getBoolean("isProd")
            }

            return TalsecConfig(
                packageName,
                certificateHashes.toTypedArray(),
                watcherMail,
                alternativeStores.toTypedArray(),
                isProd
            )
        }
    }
}