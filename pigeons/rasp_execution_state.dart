import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    input: 'pigeons/rasp_execution_state.dart',
    dartOut: 'lib/src/generated/rasp_execution_state.g.dart',
    kotlinOut:
        'android/src/main/kotlin/com/aheaditec/freerasp/generated/RaspExecutionState.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.aheaditec.freerasp.generated',
      includeErrorClass: false,
    ),
    swiftOut: 'ios/Classes/RaspExecutionState.swift',
    swiftOptions: SwiftOptions(
      fileSpecificClassNameComponent: 'Pigeon',
    )
  ),
)
@FlutterApi()
// Might be extended in the future
// ignore: one_member_abstracts
abstract class RaspExecutionState {
  void onAllChecksFinished();
}
