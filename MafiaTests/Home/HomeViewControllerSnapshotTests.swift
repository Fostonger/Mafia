@testable import Mafia
import XCTest
import FBSnapshotTestCase

final class HomeViewControllerSnapshotTests: FBSnapshotTestCase {
    private var sut: HomeViewController!
    
    override func setUp() {
        super.setUp()
        recordMode = false
        sut = HomeViewController()
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_initialState() {
        verifySnapshot()
    }
    
    private func verifySnapshot(file: StaticString = #file, line: UInt = #line) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.addSubview(sut.view)
        FBSnapshotVerifyViewController(sut, file: file, line: line)
    }
}
