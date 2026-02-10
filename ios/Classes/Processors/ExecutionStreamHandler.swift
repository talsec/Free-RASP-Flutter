import Flutter

class ExecutionStreamHandler: NSObject, FlutterStreamHandler {
    static let shared = ExecutionStreamHandler()
    private let stateProcessor = StateProcessor()

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        stateProcessor.attachSink(sink: events)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stateProcessor.detachSink()
        return nil
    }
    
    func submitFinishedEvent() {
        stateProcessor.processState(187429)
    }
}
