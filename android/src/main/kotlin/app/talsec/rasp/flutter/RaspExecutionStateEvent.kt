package app.talsec.rasp.flutter

internal sealed class RaspExecutionStateEvent(val value: Int) {
    object FastChecksFinished : RaspExecutionStateEvent(187429)

    object CriticalChecksFinished : RaspExecutionStateEvent(614702)

    object PostponedChecksFinished : RaspExecutionStateEvent(952318)
}
