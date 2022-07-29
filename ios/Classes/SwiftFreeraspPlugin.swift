import Flutter
import UIKit
import TalsecRuntime

protocol EventProcessor {
    var unprocessedEvents: [String] {get}
    func processEvent(_ event: String)
}

class ArrayEventProcessor: EventProcessor {
    private var array = [String]()
    
    var unprocessedEvents: [String] {
        array
    }
    
    func processEvent(_ event: String) {
        array.append(event)
    }
}

class SinkEventProcessor: EventProcessor {
    private let sink: FlutterEventSink
    
    init(sink: @escaping FlutterEventSink) {
        self.sink = sink
    }
    
    var unprocessedEvents: [String] {
        []
    }
    
    func processEvent(_ event: String) {
        sink(event)
    }
}

public class SwiftFreeraspPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private var eventProcessor: EventProcessor = ArrayEventProcessor() {
        didSet {
            oldValue.unprocessedEvents.forEach { eventProcessor.processEvent($0)}
        }
    }
    
    static let instance = SwiftFreeraspPlugin()
    static var eventChannel : FlutterEventChannel? = nil
    static var configChannel : FlutterMethodChannel? = nil
    private override init() {}
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        
        //Channels init
        let configChannel : FlutterMethodChannel = FlutterMethodChannel(name: "plugins.aheaditec.com/config", binaryMessenger: messenger)
        
        eventChannel = FlutterEventChannel(name: "plugins.aheaditec.com/events", binaryMessenger: messenger)
        
        eventChannel?.setStreamHandler(instance)
        registrar.addMethodCallDelegate(instance, channel: configChannel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method ==  "setConfig" else {
            print("Unimplemeted state")
            return
        }
        guard let args = call.arguments as? Dictionary<String, String>,
              let abi = args["appBundleId"],
              let ati = args["appTeamId"],
              let wm = args["watcherMail"] else {
            return //TODO: handle - if needed?
        }
        
        let config = TalsecConfig(appBundleIds: [abi], appTeamId: ati, watcherMailAddress: wm)
        Talsec.start(config: config)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventProcessor = SinkEventProcessor(sink: events)
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventProcessor = ArrayEventProcessor()
        SwiftFreeraspPlugin.eventChannel?.setStreamHandler(nil)
        return nil
    }
    
    public func submitEvent(_ submittedEvent: String) {
        eventProcessor.processEvent(submittedEvent)
    }
}

extension SecurityThreatCenter: SecurityThreatHandler {
    
    func invokeCallback(_ callback: String){
        guard !callback.isEmpty else { return }
        SwiftFreeraspPlugin.instance.submitEvent(callback)
    }
    
    public func threatDetected(_ securityThreat: TalsecRuntime.SecurityThreat) {
        invokeCallback(securityThreat.callbackIdentifier)
    }
}

extension SecurityThreat {
    var callbackIdentifier: String {
        switch self {
        case .signature:
            return "onSignatureDetected"
        case .jailbreak:
            return "onJailbreakDetected"
        case .debugger:
            return "onDebuggerDetected"
        case .runtimeManipulation:
            return "onRuntimeManipulationDetected"
        case .passcode:
            return "onPasscodeDetected"
        case .passcodeChange:
            return "onPasscodeChangeDetected"
        case .simulator:
            return "onSimulatorDetected"
        case .missingSecureEnclave:
            return "onMissingSecureEnclaveDetected"
        case .deviceChange:
            return "onDeviceChangeDetected"
        case .deviceID:
            return "onDeviceIdDetected"
        case .unofficialStore:
            return "onUnofficialStoreDetected"
        @unknown default:
            print("Undefined threat callback")
            return ""
        }
    }
}

