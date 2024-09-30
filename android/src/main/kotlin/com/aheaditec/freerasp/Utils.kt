package com.aheaditec.freerasp

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.util.Base64
import com.aheaditec.talsec_security.security.api.TalsecConfig
import org.json.JSONException
import org.json.JSONObject
import java.io.ByteArrayOutputStream

internal object Utils {
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
        return Base64.encodeToString(byteArray, Base64.DEFAULT)
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
