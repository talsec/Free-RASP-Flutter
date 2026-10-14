import Flutter
import TalsecRuntime
import XCTest

@testable import freerasp

/// Covers https://github.com/talsec/Free-RASP-Flutter/issues/231:
/// `Talsec.start` does keychain work over a synchronous XPC call, so it must not run on the
/// platform (main) thread, where it can hang the UI and trip the iOS launch watchdog.
class RunnerTests: XCTestCase {

    private let plugin = SwiftFreeraspPlugin.instance
    private var originalStarter: ((TalsecConfig) -> Void)!

    private let validConfig = """
        {"watcherMail":"security@example.com","isProd":false,\
        "iosConfig":{"bundleIds":["app.talsec.freeraspExample"],"teamId":"ABCDE12345"}}
        """

    override func setUp() {
        super.setUp()
        originalStarter = plugin.talsecStarter
    }

    override func tearDown() {
        plugin.talsecStarter = originalStarter
        super.tearDown()
    }

    private func startCall(config: String?) -> FlutterMethodCall {
        FlutterMethodCall(methodName: "start", arguments: config.map { ["config": $0] })
    }

    func testStartRunsTalsecOffTheMainThread() {
        let started = expectation(description: "Talsec started")
        var startedOnMainThread: Bool?
        plugin.talsecStarter = { _ in
            startedOnMainThread = Thread.isMainThread
            started.fulfill()
        }

        plugin.handle(startCall(config: validConfig)) { _ in }

        wait(for: [started], timeout: 2)
        XCTAssertEqual(startedOnMainThread, false)
    }

    func testStartReturnsBeforeTalsecFinishes() {
        // The starter blocks until the test releases it. If start ran inline on the main
        // thread, handle(_:result:) could not return to let the test release it.
        let release = DispatchSemaphore(value: 0)
        let finished = expectation(description: "Talsec finished")
        var waitResult: DispatchTimeoutResult?
        plugin.talsecStarter = { _ in
            waitResult = release.wait(timeout: .now() + 1)
            finished.fulfill()
        }

        plugin.handle(startCall(config: validConfig)) { _ in }
        release.signal()

        wait(for: [finished], timeout: 3)
        XCTAssertEqual(waitResult, .success)
    }

    func testStartRepliesOnTheMainThreadAfterTalsecStarts() {
        let replied = expectation(description: "result delivered")
        var talsecStarted = false
        var repliedOnMainThread: Bool?
        var reply: Any? = "unset"
        plugin.talsecStarter = { _ in talsecStarted = true }

        plugin.handle(startCall(config: validConfig)) { value in
            XCTAssertTrue(talsecStarted, "result must only be sent once Talsec.start has returned")
            repliedOnMainThread = Thread.isMainThread
            reply = value
            replied.fulfill()
        }

        wait(for: [replied], timeout: 2)
        XCTAssertEqual(repliedOnMainThread, true)
        XCTAssertNil(reply)
    }

    func testStartWithInvalidConfigReturnsErrorWithoutStartingTalsec() {
        var talsecStarted = false
        plugin.talsecStarter = { _ in talsecStarted = true }
        let replied = expectation(description: "error delivered")
        var reply: Any?

        plugin.handle(startCall(config: "not json")) { value in
            reply = value
            replied.fulfill()
        }

        wait(for: [replied], timeout: 2)
        XCTAssertEqual((reply as? FlutterError)?.code, "configuration-exception")
        XCTAssertFalse(talsecStarted)
    }
}
