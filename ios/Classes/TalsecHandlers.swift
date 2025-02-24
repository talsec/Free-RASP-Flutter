import TalsecRuntime

private let unknownValue = -1
private let signatureValue = 1115787534
private let jailbreakValue = 44506749
private let debuggerValue = 1268968002
private let runtimeManipulationValue = 209533833
private let passcodeValue = 1293399086
private let simulatorValue = 477190884
private let missingSecureEnclaveValue = 1564314755
private let deviceChangeValue = 1806586319
private let deviceIDValue =  1514211414
private let unofficialStoreValue = 629780916
private let systemVPNValue = 659382561
private let screenshotValue = 705651459
private let screenRecordingValue = 64690214

/// Extension with submits events to plugin
extension SecurityThreatCenter: SecurityThreatHandler {
    
    public func threatDetected(_ securityThreat: TalsecRuntime.SecurityThreat) {
        SwiftFreeraspPlugin.instance.submitEvent(securityThreat)
    }
}

/// An extension to unify callback names with Flutter ones.
extension SecurityThreat {
    var callbackIdentifier: Int {
        switch self {
        case .signature:
            return signatureValue
        case .jailbreak:
            return jailbreakValue
        case .debugger:
            return debuggerValue
        case .runtimeManipulation:
            return runtimeManipulationValue
        case .passcode:
            return passcodeValue
        case .passcodeChange:
            return unknownValue
        case .simulator:
            return simulatorValue
        case .missingSecureEnclave:
            return missingSecureEnclaveValue
        case .deviceChange:
            return deviceChangeValue
        case .deviceID:
            return deviceIDValue
        case .unofficialStore:
            return unofficialStoreValue
        case .systemVPN:
            return systemVPNValue
        case .screenshot:
            return screenshotValue
        case .screenRecording:
            return screenRecordingValue
        @unknown default:
            return unknownValue
        }
    }
}
