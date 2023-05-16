import TalsecRuntime

/// Model classes which represents data received from Flutter
struct FlutterTalsecConfig : Decodable {
    let watcherMail: String
    let iosConfig: IOSConfig
    let isProd: Bool
    
    func toNativeConfig() -> TalsecConfig {
        return TalsecConfig(appBundleIds: iosConfig.bundleIds, appTeamId: iosConfig.teamId, watcherMailAddress: watcherMail, isProd: isProd)
    }
}

struct IOSConfig : Decodable {
    let bundleIds: [String]
    let teamId: String
}
