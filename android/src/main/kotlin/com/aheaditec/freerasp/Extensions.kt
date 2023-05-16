package com.aheaditec.freerasp

import io.flutter.plugin.common.MethodChannel

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
