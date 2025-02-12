// Autogenerated from Pigeon (v22.4.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon
@file:Suppress("UNCHECKED_CAST", "ArrayInDataClass")

package com.aheaditec.freerasp.generated

import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

private fun createConnectionError(channelName: String): FlutterError {
  return FlutterError("channel-error",  "Unable to establish connection on channel: '$channelName'.", "")}

/**
 * Error class for passing custom error details to Flutter via a thrown PlatformException.
 * @property code The error code.
 * @property message The error message.
 * @property details The error details. Must be a datatype supported by the api codec.
 */
class FlutterError (
  val code: String,
  override val message: String? = null,
  val details: Any? = null
) : Throwable()

/** Generated class from Pigeon that represents data sent in messages. */
data class PackageInfo (
  val packageName: String,
  val appIcon: String? = null,
  val appName: String? = null,
  val version: String? = null,
  val installationSource: String? = null
)
 {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): PackageInfo {
      val packageName = pigeonVar_list[0] as String
      val appIcon = pigeonVar_list[1] as String?
      val appName = pigeonVar_list[2] as String?
      val version = pigeonVar_list[3] as String?
      val installationSource = pigeonVar_list[4] as String?
      return PackageInfo(packageName, appIcon, appName, version, installationSource)
    }
  }
  fun toList(): List<Any?> {
    return listOf(
      packageName,
      appIcon,
      appName,
      version,
      installationSource,
    )
  }
}

/** Generated class from Pigeon that represents data sent in messages. */
data class SuspiciousAppInfo (
  val packageInfo: PackageInfo,
  val reason: String
)
 {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): SuspiciousAppInfo {
      val packageInfo = pigeonVar_list[0] as PackageInfo
      val reason = pigeonVar_list[1] as String
      return SuspiciousAppInfo(packageInfo, reason)
    }
  }
  fun toList(): List<Any?> {
    return listOf(
      packageInfo,
      reason,
    )
  }
}
private open class TalsecPigeonApiPigeonCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      129.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          PackageInfo.fromList(it)
        }
      }
      130.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          SuspiciousAppInfo.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is PackageInfo -> {
        stream.write(129)
        writeValue(stream, value.toList())
      }
      is SuspiciousAppInfo -> {
        stream.write(130)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated class from Pigeon that represents Flutter messages that can be called from Kotlin. */
class TalsecPigeonApi(private val binaryMessenger: BinaryMessenger, private val messageChannelSuffix: String = "") {
  companion object {
    /** The codec used by TalsecPigeonApi. */
    val codec: MessageCodec<Any?> by lazy {
      TalsecPigeonApiPigeonCodec()
    }
  }
  fun onMalwareDetected(packageInfoArg: List<SuspiciousAppInfo>, callback: (Result<Unit>) -> Unit)
{
    val separatedMessageChannelSuffix = if (messageChannelSuffix.isNotEmpty()) ".$messageChannelSuffix" else ""
    val channelName = "dev.flutter.pigeon.freerasp.TalsecPigeonApi.onMalwareDetected$separatedMessageChannelSuffix"
    val channel = BasicMessageChannel<Any?>(binaryMessenger, channelName, codec)
    channel.send(listOf(packageInfoArg)) {
      if (it is List<*>) {
        if (it.size > 1) {
          callback(Result.failure(FlutterError(it[0] as String, it[1] as String, it[2] as String?)))
        } else {
          callback(Result.success(Unit))
        }
      } else {
        callback(Result.failure(createConnectionError(channelName)))
      } 
    }
  }
}
