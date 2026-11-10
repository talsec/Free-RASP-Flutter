// ignore_for_file: public_member_api_docs

import 'package:freerasp/freerasp.dart';

class ThreatState {
  factory ThreatState.initial() => const ThreatState._(
        detectedThreats: {},
        detectedMalware: [],
        allChecksPassed: false,
        postponedChecksPassed: false,
        callState: null,
      );

  const ThreatState._({
    required this.detectedThreats,
    required this.detectedMalware,
    required this.allChecksPassed,
    required this.postponedChecksPassed,
    required this.callState,
  });

  final Set<Threat> detectedThreats;
  final List<SuspiciousAppInfo> detectedMalware;
  final bool allChecksPassed;
  final bool postponedChecksPassed;
  final CallState? callState;

  ThreatState copyWith({
    Set<Threat>? detectedThreats,
    List<SuspiciousAppInfo>? detectedMalware,
    bool? allChecksPassed,
    bool? postponedChecksPassed,
    CallState? callState,
  }) {
    return ThreatState._(
      detectedThreats: detectedThreats ?? this.detectedThreats,
      detectedMalware:
          detectedMalware?.nonNulls.toList() ?? this.detectedMalware,
      allChecksPassed: allChecksPassed ?? this.allChecksPassed,
      postponedChecksPassed:
          postponedChecksPassed ?? this.postponedChecksPassed,
      callState: callState ?? this.callState,
    );
  }
}
