import Flutter

class ExecutionStreamHandler: NSObject, FlutterStreamHandler {
    static let shared = ExecutionStreamHandler()

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        ExecutionStateDispatcher.shared.listener = { state in
            events(state.rawValue)
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        ExecutionStateDispatcher.shared.listener = nil
        return nil
    }
}
