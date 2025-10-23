// ignore_for_file: public_member_api_docs

import 'package:freerasp/freerasp.dart';

class ThreatState {
  factory ThreatState.initial() => const ThreatState._(
        detectedThreats: {},
        detectedMalware: [],
        allChecksPassed: false,
      );

  const ThreatState._({
    required this.detectedThreats,
    required this.detectedMalware,
    required this.allChecksPassed,
  });

  final Set<Threat> detectedThreats;
  final List<SuspiciousAppInfo> detectedMalware;
  final bool allChecksPassed;

  ThreatState copyWith({
    Set<Threat>? detectedThreats,
    List<SuspiciousAppInfo>? detectedMalware,
    bool? allChecksPassed,
  }) {
    return ThreatState._(
      detectedThreats: detectedThreats ?? this.detectedThreats,
      detectedMalware:
          detectedMalware?.nonNulls.toList() ?? this.detectedMalware,
      allChecksPassed: allChecksPassed ?? this.allChecksPassed,
    );
  }
}
