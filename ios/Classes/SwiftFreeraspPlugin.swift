import Flutter
import UIKit
import TalsecRuntime

/// A Flutter plugin that interacts with the Talsec runtime library, handles method calls and provides event streams.
public class SwiftFreeraspPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    /// The event processor used to handle and dispatch events.
    private let eventProcessor = EventProcessor()
    
    private static let stateProcessor = StateProcessor()
    
    /// The singleton instance of `SwiftTalsecPlugin`.
    static let instance = SwiftFreeraspPlugin()
    
    private var raspExecutionStatePigeon: RaspExecutionStateProtocol? = nil
    
    private override init() {}
    
    /// Registers this plugin with the given `FlutterPluginRegistrar`.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let eventChannel = FlutterEventChannel(name: "talsec.app/freerasp/events", binaryMessenger: messenger)
        eventChannel.setStreamHandler(instance)
        
        //Channels init
        let methodChannel : FlutterMethodChannel = FlutterMethodChannel(name: "talsec.app/freerasp/methods", binaryMessenger: messenger)
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        let pigeon = RaspExecutionState(binaryMessenger: messenger)
        stateProcessor.attachPigeon(pigeon: pigeon)
    }
    
    /// Handles a method call from Flutter.
    ///
    /// - Parameters:
    ///   - call: The `FlutterMethodCall` object representing the method call.
    ///   - result: The `FlutterResult` object to be returned to the caller.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? Dictionary<String, Any> ?? [:]
        
        switch call.method {
        case "start":
            start(configJson: args["config"] as? String, result: result)
            return
        case "blockScreenCapture":
            blockScreenCapture(enable: args["enable"] as? Bool, result: result)
            return
        case "isScreenCaptureBlocked":
            isScreenCaptureBlocked(result: result)
            return
        case "storeExternalId":
            storeExternalId(data: args["data"] as? String, result: result)
            return
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /// Runs Talsec with given configuration
    ///
    /// - Parameters:
    ///   - args: The arguments received from Flutter which contains configuration
    ///   - result: The `FlutterResult` object to be returned to the caller.
    private func start(configJson: String?, result: @escaping FlutterResult) {
        guard let data = configJson?.data(using: .utf8),
              let flutterConfig = try? JSONDecoder().decode(FlutterTalsecConfig.self, from: data)
        else {
            result(FlutterError(code: "configuration-exception", message: "Unable to decode configuration", details: nil))
            return
        }
        
        Talsec.start(config: flutterConfig.toNativeConfig())

        // Flutter expects *some* result to be returned even if it's void
        result(nil)
    }
    
    /// Blocks screen capture for the current UIWindow.
    ///
    /// - Parameters:
    ///   - enable: Whether screen capture should be enabled / disabled.
    ///   - result: The `FlutterResult` object to be returned to the caller.
    private func blockScreenCapture(enable: Bool?, result: @escaping FlutterResult){
        guard let enableSafe = enable else {
            result(FlutterError(code: "block-screen-capture-failure", message: "Couldn't process data.", details: nil))
            return
        }
        
        getProtectedWindow { window in
            if let window = window {
                Talsec.blockScreenCapture(enable: enableSafe, window: window)
                result(nil)
            } else {
                result(FlutterError(code: "block-screen-capture-failure", message: "No windows found to block screen capture", details: nil))
            }
        }
    }
    
    /// Determines whether screen capture is blocked for the current UIWindow.
    ///
    /// - Parameters:
    ///   - nonce: The nonce to be used in the cryptogram calculation.
    ///   - result: The `FlutterResult` object to be returned to the caller.
    private func isScreenCaptureBlocked(result: @escaping FlutterResult){
        getProtectedWindow { window in
            if let window = window {
                let isBlocked = Talsec.isScreenCaptureBlocked(in: window)
                result(isBlocked)
            } else {
                result(FlutterError(code: "is-screen-capture-blocked-failure", message: "Error while checking if screen capture is blocked", details: nil))
            }
        }
    }
    
    private func getProtectedWindow(completion: @escaping (UIWindow?) -> Void) {
        DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    if let window = windowScene.windows.first {
                        completion(window)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    /// Stores the external ID in user defaults.
    ///
    /// - Parameters:
    ///   - data: The data to be stored.
    ///   - result: The `FlutterResult` object to be returned to the caller.
    private func storeExternalId(data: String?, result: @escaping FlutterResult){
        UserDefaults.standard.set(data, forKey: "app.talsec.externalid")
        result(nil)
    }
    
    /// Attaches a FlutterEventSink to the EventProcessor and processes any detectedThreats in the queue.
    ///
    /// - Parameters:
    /// - arguments: Unused
    /// - events: The FlutterEventSink to be attached to the EventProcessor.
    /// - Returns: Always returns nil.
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventProcessor.attachSink(sink: events)
        return nil
    }
    
    // Detaches the current FlutterEventSink from the EventProcessor.
    ///
    /// - Parameters:
    /// - arguments: Unused
    /// - Returns: Always returns nil.
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventProcessor.detachSink()
        return nil
    }
    
    /// Processes a submitted SecurityThreat event.
    ///
    /// - Parameters:
    /// - submittedEvent: The SecurityThreat event to be processed.
    public func submitEvent(_ submittedEvent: SecurityThreat) {
        if (submittedEvent == SecurityThreat.passcodeChange){
            return
        }
        eventProcessor.processEvent(submittedEvent)
    }
    
    /// Submits a finished event to notify Flutter that all security checks are complete.
    ///
    /// This method is called by the native security engine when all security
    /// validation checks have been completed. It triggers the state processor
    /// to send a completion notification to Flutter through the Pigeon protocol.
    ///
    /// This method should be called after the security engine has finished
    /// executing all its validation routines.
    public func submitFinishedEvent() {
        SwiftFreeraspPlugin.stateProcessor.processState()
    }
}
