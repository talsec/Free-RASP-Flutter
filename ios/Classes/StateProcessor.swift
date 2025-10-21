/// A class responsible for managing RASP execution state communication with Flutter.
class StateProcessor {
    /// Tracks whether security checks have been completed.
    private var hasChecksFinished = false
    
    /// The Pigeon protocol instance used for communication with Flutter.
    private var raspStatePigeon: RaspExecutionStateProtocol?
    
    /// Attaches a Pigeon protocol instance for RASP execution state communication.
    ///
    /// - Parameter pigeon: The Pigeon protocol instance for communication with Flutter.
    func attachPigeon(pigeon: RaspExecutionStateProtocol) {
        self.raspStatePigeon = pigeon
        if (hasChecksFinished) {
            processState()
        }
    }
    
    /// Detaches the current Pigeon protocol instance.
    func detachPigeon() {
        self.raspStatePigeon = nil
    }
    
    /// Processes the execution state by notifying Flutter of completion.
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
