import Foundation

class ExecutionStateDispatcher {
    static let shared = ExecutionStateDispatcher()
    // Ordered, so a listener attached late still receives the states in the order they occurred
    private var cache: [RaspExecutionStates] = []
    private let lock = NSLock()
    
    var listener: ((RaspExecutionStates) -> Void)? {
        didSet {
            if listener != nil {
                flushCache()
            }
        }
    }

    func dispatch(event: RaspExecutionStates) {
        lock.lock()
        defer { lock.unlock() }
        
        if let listener = listener {
            listener(event)
        } else if !cache.contains(event) {
            cache.append(event)
        }
    }

    private func flushCache() {
        lock.lock()
        let events = cache
        cache.removeAll()
        lock.unlock()
        
        events.forEach { listener?($0) }
    }
}
