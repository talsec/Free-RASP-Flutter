// ignore_for_file: public_member_api_docs

import 'package:freerasp/freerasp.dart';

class ThreatState {
  factory ThreatState.initial() =>
      const ThreatState._(detectedThreats: {}, detectedMalware: []);

  const ThreatState._({
    required this.detectedThreats,
    required this.detectedMalware,
  });

  final Set<Threat> detectedThreats;
  final List<SuspiciousAppInfo> detectedMalware;

  ThreatState copyWith({
    Set<Threat>? detectedThreats,
    List<SuspiciousAppInfo>? detectedMalware,
  }) {
    return ThreatState._(
      detectedThreats: detectedThreats ?? this.detectedThreats,
      detectedMalware:
          detectedMalware?.nonNulls.toList() ?? this.detectedMalware,
    );
  }
}
