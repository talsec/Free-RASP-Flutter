import 'package:freerasp/src/generated/rasp_execution_state.g.dart' as pigeon;
import 'package:freerasp/src/typedefs.dart';

class RaspExecutionStateCallback extends pigeon.RaspExecutionState {
  final VoidCallback? onAllChecksDone;

  RaspExecutionStateCallback({
    this.onAllChecksDone,
  });

  @override
  void onAllChecksFinished() {
    onAllChecksDone?.call();
  }
}
