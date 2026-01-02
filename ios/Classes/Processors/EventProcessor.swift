import TalsecRuntime

/// A class responsible for processing and managing security threat events.
///
/// The `EventProcessor` handles the communication of security threat events from
/// the native security engine to Flutter. It provides a queuing mechanism for
/// events that occur before a Flutter listener is attached, ensuring no events
/// are lost during the initialization phase.
///
/// This class implements a producer-consumer pattern where security threats are
/// produced by the native engine and consumed by Flutter through event streams.
class EventProcessor {
    /// A set of security threats that have been detected but not yet processed.
    ///
    /// This collection serves as a queue for security threat events that occur
    /// before a Flutter event sink is attached. Events are stored here until
    /// a sink becomes available for processing.
    private var detectedThreats = Set<SecurityThreat>()
    
    /// A sink for sending processed security threat events to Flutter.
    ///
    /// This property holds the Flutter event sink that is used to send security
    /// threat events to the Flutter side. When nil, events are queued in the
    /// `detectedThreats` set for later processing.
    private var sink: FlutterEventSink?
    
    /// Attaches a new sink for sending processed security threat events.
    ///
    /// This method should be called in the `onListen` callback of a `FlutterStreamHandler`.
    /// When a sink is attached, any previously queued events are immediately
    /// processed and sent to Flutter.
    ///
    /// - Parameter sink: A closure that takes a `String` argument and returns void.
    ///   This closure is used to send processed security threat events to Flutter.
    func attachSink(sink: @escaping FlutterEventSink){
        self.sink = sink
        detectedThreats.forEach(processEvent)
        detectedThreats.removeAll()
    }
    
    /// Detaches the current sink.
    ///
    /// This method should be called in the `onCancel` callback of a `FlutterStreamHandler`.
    /// After detaching, new security threat events will be queued until a new
    /// sink is attached.
    func detachSink(){
        self.sink = nil
    }
    
    /// Processes a security threat event.
    ///
    /// This method handles the processing of individual security threat events.
    /// If a Flutter event sink is available, the event is immediately sent to
    /// Flutter. Otherwise, the event is cached in the `detectedThreats` set
    /// for later processing when a sink becomes available.
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
