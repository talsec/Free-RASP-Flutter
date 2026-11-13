import TalsecRuntime

/// Model classes which represents data received from Flutter
struct FlutterTalsecConfig : Decodable {
    let watcherMail: String
    let iosConfig: IOSConfig
    let isProd: Bool
    
    func toNativeConfig() -> TalsecConfig {
        return TalsecConfig(appBundleIds: iosConfig.appBundleIds, appTeamId: iosConfig.appTeamId, watcherMailAddress: watcherMail, isProd: isProd)
    }
}

struct IOSConfig : Decodable {
    let appBundleIds: [String]
    let appTeamId: String
}
