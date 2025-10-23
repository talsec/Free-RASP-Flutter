class StateProcessor {
    private var hasChecksFinished = false
    
    private var raspStatePigeon: RaspExecutionStateProtocol?
    
    func attachPigeon(pigeon: RaspExecutionStateProtocol) {
        self.raspStatePigeon = pigeon
        if (hasChecksFinished) {
            processState()
        }
    }
    
    func detachPigeon() {
        self.raspStatePigeon = nil
    }
    
    func processState() {
        guard let pigeon = raspStatePigeon else {
            hasChecksFinished = true
            return
        }
        
        pigeon.onAllChecksFinished{
            result in
               if case .failure(let error) = result {
                   print("Error: \(error)")
               } else {
                   print("Success!")
               }
        }
    }
}
