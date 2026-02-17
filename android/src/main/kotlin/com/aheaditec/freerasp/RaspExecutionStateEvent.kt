package com.aheaditec.freerasp

internal sealed class RaspExecutionStateEvent(val value: Int) {
    object AllChecksFinished : RaspExecutionStateEvent(187429)
}
