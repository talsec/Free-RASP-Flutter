/// Model class for iOS config
///
/// Contains crucial data that are passed to native side in order to secure Android device.
class IOSconfig {
  // Nullable because of older Dart SDK versions
  // see issue https://github.com/talsec/Free-RASP-Flutter/issues/6
  final String? appBundleId;
  final String? appTeamId;

  /// Constructor checks whether [appTeamId] and [appBundleId] are provided.
  /// Both arguments are MANDATORY.
  const IOSconfig({
    required final this.appBundleId,
    required final this.appTeamId,
  }) : assert(
          appBundleId != null && appTeamId != null,
          'appBundleId and appTeamId cannot be null.',
        );
}
