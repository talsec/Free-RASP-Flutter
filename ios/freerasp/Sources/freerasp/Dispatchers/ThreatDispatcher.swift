import Foundation
import TalsecRuntime

class ThreatDispatcher {
    static let shared = ThreatDispatcher()
    private var threatCache: Set<SecurityThreat> = []
    private let lock = NSLock()
    
    var listener: ((SecurityThreat) -> Void)? {
        didSet {
            if listener != nil {
                flushCache()
            }
        }
    }

    func dispatch(threat: SecurityThreat) {
        lock.lock()
        defer { lock.unlock() }
        
        if let listener = listener {
            listener(threat)
        } else {
            threatCache.insert(threat)
        }
    }

    private func flushCache() {
        lock.lock()
        let threats = threatCache
        threatCache.removeAll()
        lock.unlock()
        
        threats.forEach { listener?($0) }
    }
}
