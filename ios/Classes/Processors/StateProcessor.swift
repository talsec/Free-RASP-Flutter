class StateProcessor {
    private var cachedEvents: [Int] = []
    
    private var sink: FlutterEventSink?
    
    func attachSink(sink: @escaping FlutterEventSink) {
        self.sink = sink
        cachedEvents.forEach(processState)
        cachedEvents.removeAll()
    }
    
    func detachSink() {
        self.sink = nil
    }
    
    func processState(_ value: Int) {
        guard let eventSink = sink else {
            cachedEvents.append(value)
            return
        }
        eventSink(value)
    }
}
