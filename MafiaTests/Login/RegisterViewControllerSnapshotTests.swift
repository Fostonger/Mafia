@testable import Mafia
import XCTest
import FBSnapshotTestCase

final class RegisterViewControllerSnapshotTests: FBSnapshotTestCase {
    private var sut: RegisterViewController!
    private var apiClient: MafiaAPIClientStub!
    private var defaults: MafiaUserDefaultsMock!
    private var coordinator: DummyCoordinator!
    
    override func setUp() {
        super.setUp()
        recordMode = false
        apiClient = MafiaAPIClientStub()
        defaults = MafiaUserDefaultsMock()
        coordinator = DummyCoordinator()
        sut = RegisterViewController.make(client: apiClient, defaults: defaults, delegate: coordinator)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        apiClient = nil
        defaults = nil
        sut = nil
        super.tearDown()
    }
    
    func test_snapshotRegisterViewController() {
        verifySnapshot()
    }
    
    private func verifySnapshot(file: StaticString = #file, line: UInt = #line) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.addSubview(sut.view)
        FBSnapshotVerifyViewController(sut, file: file, line: line)
    }
}
