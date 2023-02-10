@testable import Mafia
import XCTest

final class RegisterViewControllerTests: XCTestCase {
    private var sut: RegisterViewController!
    private var apiClient: MafiaAPIClient!
    private var defaults: MafiaUserDefaultsProtocol!
    
    override func setUp() {
        super.setUp()
        apiClient = MafiaAPIClientStub()
        defaults = MafiaUserDefaultsMock()
        sut = RegisterViewController()
        sut.model = RegisterViewModel(client: apiClient, defaults: defaults)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        apiClient = nil
        defaults = nil
        sut = nil
        super.tearDown()
    }
    
    func test_textFieldsDelegate_shouldNotBeNil() {
        XCTAssertNotNil(sut.nicknameTextField.delegate, "nickname")
        XCTAssertNotNil(sut.passwordTextField.delegate, "password")
    }
}
