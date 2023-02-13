@testable import Mafia
import XCTest
import FBSnapshotTestCase

final class LoginViewControllerSnapshotTests: FBSnapshotTestCase {
    private var sut: LoginViewController!
    private var apiClient: MafiaAPIClientStub!
    private var defaults: MafiaUserDefaultsMock!
    private var coordinator: DummyCoordinator!
    
    override func setUp() {
        super.setUp()
        recordMode = false
        apiClient = MafiaAPIClientStub()
        defaults = MafiaUserDefaultsMock()
        coordinator = DummyCoordinator()
        sut = LoginViewController.make(client: apiClient, defaults: defaults, delegate: coordinator)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        apiClient = nil
        defaults = nil
        sut = nil
        super.tearDown()
    }
    
    func test_initialState() {
        verifySnapshot(sut)
    }
    
    private func verifySnapshot(_ vc: UIViewController, file: StaticString = #file, line: UInt = #line) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.addSubview(sut.view)
        FBSnapshotVerifyViewController(vc, file: file, line: line)
    }
}
