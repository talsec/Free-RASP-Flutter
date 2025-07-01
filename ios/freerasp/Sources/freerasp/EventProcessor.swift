import TalsecRuntime
import Flutter

/// Class for processing security threat events
class EventProcessor {
    /// A set of security threats that have been detected but not yet processed
    private var detectedThreats = Set<SecurityThreat>()
    
    /// A sink for sending processed security threat events
    private var sink: FlutterEventSink?
    
    /// Attaches a new sink for sending processed security threat events.
    ///
    /// This should be called in onListen callback in FlutterStreamHandler.
    ///
    /// - Parameter sink: A closure that takes a `String` argument and returns void. This closure is used to send processed security threat events to the sink.
    func attachSink(sink: @escaping FlutterEventSink){
        self.sink = sink
        detectedThreats.forEach(processEvent)
        detectedThreats.removeAll()
    }
    
    /// Detaches the current sink.
    ///
    /// This should be called in onCancel callback in FlutterStreamHandler.
    func detachSink(){
        self.sink = nil
    }
    
    /// Processes a security threat event.
    ///
    /// If a sink is attached, the event is sent to Flutter via the sink. Otherwise, the event is cached in the `detectedThreats` set for later processing.
    ///
    /// - Parameter event: The `SecurityThreat` event to be processed.

    func processEvent(_ event: SecurityThreat){
        guard let eventSink = sink else {
            detectedThreats.insert(event)
            return
        }
        
        eventSink(event.callbackIdentifier)
    }
}
