import Foundation

class ExecutionStateDispatcher {
    static let shared = ExecutionStateDispatcher()
    private var cache: Set<RaspExecutionStates> = []
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
        } else {
            cache.insert(event)
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
