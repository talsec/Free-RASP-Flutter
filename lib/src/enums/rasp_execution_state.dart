/// Represents the state of the RASP (Runtime Application Self-Protection)
/// execution.
enum RaspExecutionState {
  /// All security checks have been completed.
  allChecksFinished,
}

/// Extensions for [RaspExecutionState].
extension RaspExecutionStateX on RaspExecutionState {
  /// Converts an integer value to a [RaspExecutionState].
  static RaspExecutionState fromInt(int value) {
    switch (value) {
      case 187429:
        return RaspExecutionState.allChecksFinished;
      default:
        throw ArgumentError('Unknown execution state code: $value');
    }
  }
}
