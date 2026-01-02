package com.aheaditec.freerasp

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.util.Base64
import com.aheaditec.talsec_security.security.api.TalsecConfig
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.io.ByteArrayOutputStream

internal object Utils {
    @Suppress("ArrayInDataClass")
    data class MalwareConfig(
        val blacklistedPackageNames: Array<String>,
        val blacklistedHashes: Array<String>,
        val suspiciousPermissions: Array<Array<String>>,
        val whitelistedInstallationSources: Array<String>
    )

    fun toTalsecConfigThrowing(configJson: String?): TalsecConfig {
        if (configJson == null) {
            throw JSONException("Configuration is null")
        }

        val json = JSONObject(configJson)

        val watcherMail = json.getString("watcherMail")
        val isProd = json.getBoolean("isProd")
        val killOnBypass = json.optBoolean("killOnBypass")
        val androidConfig = json.getJSONObject("androidConfig")
        val packageName = androidConfig.getString("packageName")
        val certificateHashes = androidConfig.extractArray<String>("signingCertHashes")
        val alternativeStores = androidConfig.extractArray<String>("supportedStores")
        val malwareConfig = parseMalwareConfig(androidConfig)

        return TalsecConfig.Builder(packageName, certificateHashes)
            .watcherMail(watcherMail)
            .supportedAlternativeStores(alternativeStores)
            .prod(isProd)
            .killOnBypass(killOnBypass)
            .blacklistedPackageNames(malwareConfig.blacklistedPackageNames)
            .blacklistedHashes(malwareConfig.blacklistedHashes)
            .suspiciousPermissions(malwareConfig.suspiciousPermissions)
            .whitelistedInstallationSources(malwareConfig.whitelistedInstallationSources)
            .build()
    }

    private fun parseMalwareConfig(androidConfig: JSONObject): MalwareConfig {
        if (!androidConfig.has("malwareConfig")) {
            return MalwareConfig(emptyArray(), emptyArray(), emptyArray(), emptyArray())
        }

        val malwareConfig = androidConfig.getJSONObject("malwareConfig")

        return MalwareConfig(
            malwareConfig.extractArray("blacklistedPackageNames"),
            malwareConfig.extractArray("blacklistedHashes"),
            malwareConfig.extractArray<Array<String>>("suspiciousPermissions"),
            malwareConfig.extractArray("whitelistedInstallationSources")
        )
    }


    /**
     * Retrieves the package name of the installer for a given app package.
     *
     * @param context The context of the application.
     * @param packageName The package name of the app whose installer package name is to be retrieved.
     * @return The package name of the installer if available, or `null` if not.
     */
    fun getInstallerPackageName(context: Context, packageName: String): String? {
        runCatching {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
                return context.packageManager.getInstallSourceInfo(packageName).installingPackageName
            @Suppress("DEPRECATION")
            return context.packageManager.getInstallerPackageName(packageName)
        }
        return null
    }

    /**
     * Converts the application icon of the specified package into a Base64 encoded string.
     *
     * @param context The context of the application.
     * @param packageName The package name of the app whose icon is to be converted.
     * @return A Base64 encoded string representing the app icon.
     */
    fun parseIconBase64(context: Context, packageName: String): String? {
        val result = runCatching {
            val drawable = context.packageManager.getApplicationIcon(packageName)
            val bitmap = drawable.toBitmap()
            bitmap.toBase64()
        }

        return result.getOrNull()
    }

    /**
     * Creates a Bitmap from a Drawable object.
     *
     * @param drawable The Drawable to be converted.
     * @return A Bitmap representing the drawable.
     */
    private fun createBitmapFromDrawable(drawable: Drawable): Bitmap {
        val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 1
        val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 1
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)

        return bitmap
    }

    /**
     * Converts a Drawable into a Bitmap.
     *
     * @receiver The Drawable to be converted.
     * @return A Bitmap representing the drawable.
     */
    private fun Drawable.toBitmap(): Bitmap {
        return when (this) {
            is BitmapDrawable -> bitmap
            else -> createBitmapFromDrawable(this)
        }
    }

    /**
     * Converts a Bitmap into a Base64 encoded string.
     *
     * @receiver The Bitmap to be converted.
     * @return A Base64 encoded string representing the bitmap.
     */
    private fun Bitmap.toBase64(): String {
        val byteArrayOutputStream = ByteArrayOutputStream()
        compress(Bitmap.CompressFormat.PNG, 10, byteArrayOutputStream)
        val byteArray = byteArrayOutputStream.toByteArray()
        return Base64.encodeToString(byteArray, Base64.NO_WRAP)
    }
}

private inline fun <reified T> JSONObject.extractArray(key: String): Array<T> {
    return this.optJSONArray(key)?.let { processArray(it) } ?: emptyArray()
}

private inline fun <reified T> processArray(jsonArray: JSONArray): Array<T> {
    val list = mutableListOf<T>()

    for (i in 0 until jsonArray.length()) {
        val element: T = when (T::class) {
            String::class -> jsonArray.getString(i) as T
            Int::class -> jsonArray.getInt(i) as T
            Double::class -> jsonArray.getDouble(i) as T
            Boolean::class -> jsonArray.getBoolean(i) as T
            Long::class -> jsonArray.getLong(i) as T
            Array<String>::class -> {
                // Not universal or ideal solution, but should work for our use case
                val nestedArray = jsonArray.getJSONArray(i)
                val nestedList = mutableListOf<String>()
                for (j in 0 until nestedArray.length()) {
                    nestedList.add(nestedArray.getString(j))
                }
                nestedList.toTypedArray() as T
            }

            else -> throw JSONException("Unsupported type")
        }
        list.add(element)
    }

    return list.toTypedArray()
}