package com.aheaditec.freerasp

import android.content.Context
import android.content.pm.PackageInfo
import android.os.Build
import com.aheaditec.talsec_security.security.api.SuspiciousAppInfo
import io.flutter.plugin.common.MethodChannel
import com.aheaditec.freerasp.generated.PackageInfo as FlutterPackageInfo
import com.aheaditec.freerasp.generated.SuspiciousAppInfo as FlutterSuspiciousAppInfo

/**
 * Executes the provided block of code and catches any exceptions thrown by it, returning the
 * exception as an error result through the [result] parameter. This function is intended to be used
 * when executing asynchronous code that is initiated by a Flutter method call and that must return
 * a result to Flutter.
 *
 * @param result The Flutter [MethodChannel.Result] object to return the result to.
 */
internal inline fun runResultCatching(result: MethodChannel.Result, block: () -> Unit) {
    return try {
        block.invoke()
    } catch (err: Throwable) {
        result.error(err::class.java.name, err.message, null)
    }
}

/**
 * Converts a [SuspiciousAppInfo] instance to a [com.aheaditec.freerasp.generated.SuspiciousAppInfo]
 * instance used by Pigeon package for Flutter.
 *
 * @return A new [com.aheaditec.freerasp.generated.SuspiciousAppInfo] object with information from
 * this [SuspiciousAppInfo].
 */
internal fun SuspiciousAppInfo.toPigeon(context: Context): FlutterSuspiciousAppInfo {
    return FlutterSuspiciousAppInfo(this.packageInfo.toPigeon(context), this.reason)
}

/**
 * Converts a [PackageInfo] instance to a [com.aheaditec.freerasp.generated.PackageInfo] instance
 * used by Pigeon package for Flutter.
 *
 * @return A new [com.aheaditec.freerasp.generated.PackageInfo] object with information from
 * this [PackageInfo].
 */
private fun PackageInfo.toPigeon(context: Context): FlutterPackageInfo {
    return FlutterPackageInfo(
        packageName = packageName,
        appName = context.packageManager.getApplicationLabel(applicationInfo) as String,
        version = getVersionString(),
        appIcon = Utils.parseIconBase64(context, packageName),
        installationSource = Utils.getInstallerPackageName(context, packageName),
    )
}

/**
 * Retrieves the version string of the package.
 *
 * For devices running on Android P (API 28) and above, this method returns the `longVersionCode`.
 * For older versions, it returns the `versionCode` (deprecated).
 *
 * @return A string representation of the version code.
 */
internal fun PackageInfo.getVersionString(): String {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        return longVersionCode.toString()
    }
    @Suppress("DEPRECATION")
    return versionCode.toString()
}

/**
 * Returns the encapsulated value if this instance represents success or throws the encapsulated exception
 * if it is a failure, executing the given action before throwing.
 *
 * This function is similar to `Result.getOrThrow()`, but with the added functionality of performing
 * an action before throwing the exception.
 *
 * @param action The action to be executed if the result is a failure. This action should not throw an exception.
 * @return The encapsulated value if the result is a success.
 * @throws Throwable The encapsulated exception if the result is a failure.
 *
 * @see Result.getOrThrow
 */
inline fun <T> Result<T>.getOrElseThenThrow(action: () -> Unit): T {
    return getOrElse {
        action()
        throw it
    }
}