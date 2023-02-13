@testable import Mafia
import XCTest
import ViewControllerPresentationSpy

final class LoginViewControllerTests: XCTestCase {
    private var alertVerifier: AlertVerifier!
    private var sut: LoginViewController!
    private var apiClient: MafiaAPIClientStub!
    private var defaults: MafiaUserDefaultsMock!
    private var coordinator: DummyCoordinator!
    
    @MainActor override func setUp() {
        super.setUp()
        alertVerifier = AlertVerifier()
        apiClient = MafiaAPIClientStub()
        defaults = MafiaUserDefaultsMock()
        coordinator = DummyCoordinator()
        sut = LoginViewController.make(client: apiClient, defaults: defaults, delegate: coordinator)
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        alertVerifier = nil
        apiClient = nil
        defaults = nil
        sut = nil
        super.tearDown()
    }
    
    // MARK: TextField delegate
    
    func test_textFieldsDelegate_shouldNotBeNil() {
        XCTAssertNotNil(sut.nicknameTextField.delegate, "nickname")
        XCTAssertNotNil(sut.passwordTextField.delegate, "password")
    }
    
    func test_shouldReturn_withNickname_shouldMoveInputFocusToPassword() {
        putInViewHierarchy(sut)
        
        shouldReturn(in: sut.nicknameTextField)
        
        XCTAssertTrue(sut.passwordTextField.isFirstResponder)
    }
    
    func test_shouldReturn_withPassword_shouldDismissKeyboard() {
        putInViewHierarchy(sut)
        
        shouldReturn(in: sut.passwordTextField)
        
        XCTAssertFalse(sut.passwordTextField.isFirstResponder, "password")
        XCTAssertFalse(sut.nicknameTextField.isFirstResponder, "nickname")
    }
    
    func test_emptyNicknameAndPassword_registerButtonShouldBeDisabled() {
        XCTAssertFalse(sut.loginButton.isEnabled)
        XCTAssertTrue(sut.registerButton.isEnabled)
    }
    
    func test_setNickname_withoutPassword_registerButtonShouldBeDisabled() {
        shouldChangeCharacters(in: sut.nicknameTextField, replacement: "DUMMY")
        
        XCTAssertFalse(sut.loginButton.isEnabled)
    }
    
    func test_setCorrectNicknameAndPassword_registerButtonShouldBeEnabled() {
        setCorrectCredentials()
        
        XCTAssertTrue(sut.loginButton.isEnabled)
    }
    
    func test_sendRegisterRequest_registerButtonShouldBeDisabled() {
        setCorrectCredentials()
        tap(sut.loginButton)
        
        XCTAssertFalse(sut.loginButton.isEnabled)
    }
    
    func test_sendRegisterRequest_shouldSendOneRequest() {
        setCorrectCredentials()
        tap(sut.loginButton)
        
        XCTAssertEqual(apiClient.dataTaskCallCount, 1)
    }
    
    
    @MainActor func test_sendRegisterRequest_withError_shouldShowAlert() {
        setCorrectCredentials()
        tap(sut.loginButton)
        let alertShown = expectation(description: "alert shown")
        alertVerifier.testCompletion = {
            alertShown.fulfill()
        }
        apiClient.dataTaskArgsCompletionHandler.first?(nil, nil, nil)
        
        waitForExpectations(timeout: 0.01)
        
        checkAlert(message: APIError.invalidData.errorDescription)
    }
    
    @MainActor func test_sendRegisterRequest_withNilData_shouldShowAlert() {
        setCorrectCredentials()
        tap(sut.loginButton)
        let alertShown = expectation(description: "alert shown")
        alertVerifier.testCompletion = {
            alertShown.fulfill()
        }
        apiClient.dataTaskArgsCompletionHandler.first?(nil, nil, TestError(message: "error"))
        
        waitForExpectations(timeout: 0.01)
        
        checkAlert(message: "error")
    }
    
    @MainActor func test_sendRegisterRequest_withInvalidData_withAsync_shouldOpenHomeView() throws {
        setCorrectCredentials()
        tap(sut.loginButton)
        let completionHandlerCalled = expectation(description: "completionHandler called")
        
        alertVerifier.testCompletion = {
            completionHandlerCalled.fulfill()
        }
        
        apiClient.dataTaskArgsCompletionHandler.first?(try invalidUserData(), nil, nil)
        
        waitForExpectations(timeout: 0.01)
        
        checkAlert(message: APIError.invalidType.errorDescription)
    }
    
    func test_sendRegisterRequest_withValidData_withoutAsync_shouldNotOpenHomeView() throws {
        setCorrectCredentials()
        tap(sut.loginButton)
        
        apiClient.dataTaskArgsCompletionHandler.first?(try validUserData(), nil, nil)
        
        XCTAssertEqual(coordinator.callCount, 0)
    }
    
    func test_sendRegisterRequest_withValidData_withAsync_shouldOpenHomeView() throws {
        setCorrectCredentials()
        tap(sut.loginButton)
        let completionHandlerCalled = expectation(description: "completionHandler called")
        defaults.completionHandler = { _ in
            completionHandlerCalled.fulfill()
        }
        
        apiClient.dataTaskArgsCompletionHandler.first?(try validUserData(), nil, nil)
        
        waitForExpectations(timeout: 0.01)
        
        XCTAssertEqual(coordinator.callCount, 1)
    }
    
    func test_tapOnRegisterButton_shouldOpenRegisterViewController() {
        let navigation = UINavigationController(rootViewController: sut)
        tap(sut.registerButton)
        executeRunLoop()
        
        XCTAssertEqual(navigation.viewControllers.count, 2, "navigation stack")
        
        let pushedVC = navigation.viewControllers.last
        
        guard let _ = pushedVC as? RegisterViewController else {
            XCTFail("Expected CodeNextViewController, "
                    + "but was \(String(describing: pushedVC))")
            return
        }
    }
    
    private func validUserData() throws -> Data {
        let userId = 0
        let encoder = JSONEncoder()
        return try encoder.encode(userId)
    }
    
    private func invalidUserData() throws -> Data {
        let string = "DUMMY"
        let encoder = JSONEncoder()
        return try encoder.encode(string)
    }
    
    private func setCorrectCredentials() {
        sut.passwordTextField.text = "DUMMY PASSWORD"
        sut.nicknameTextField.text = "DUMMY NICKNAME"
        shouldChangeCharacters(in: sut.passwordTextField, replacement: "DUMMY")
    }
    
    @MainActor func checkAlert(message: String?, file: StaticString = #file, line: UInt = #line) {
        alertVerifier.verify(
            title: "Ошибка при входе",
            message: message,
            animated: true,
            actions: [
                .default("OK"),
            ],
            presentingViewController: sut,
            file: file,
            line: line
        )
        XCTAssertEqual(alertVerifier.preferredAction?.title, "OK", "preferred action", file: file, line: line)
    }
}
