@testable import Mafia
import XCTest
import ViewControllerPresentationSpy

final class HomeCoordinatorTests: XCTestCase {
    private var sut: HomeViewController!
    private var coordinator: HomeCoordinator!
    private var client: MafiaAPIClientStub!
    private var user: User!
    private var alertVerifier: AlertVerifier!
    
    @MainActor override func setUp() {
        super.setUp()
        client = MafiaAPIClientStub()
        user = User(id: 0, username: "DUMMY")
        coordinator = HomeCoordinator.make(user: user, client: client)
        sut = coordinator.viewControllers.first as? HomeViewController
        alertVerifier = AlertVerifier()
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        client = nil
        user = nil
        sut = nil
        coordinator = nil
        alertVerifier = nil
        super.tearDown()
    }
    
    // MARK: Achievements
    
    func test_loadAchievements_requestshouldBeSent() {
        makeViewAppear()
        XCTAssertEqual(client.dataTaskCallCount, 1)
    }
    
    func test_loadAchievements_withoutAsync_textShouldNotBeSet() throws {
        makeViewAppear()
        
        client.dataTaskArgsCompletionHandler.first?(try achievementsValidData(), nil, nil)
        
        XCTAssertEqual(sut.achievementsLabel.text, "Подождите, загружаем данные...")
    }
    
    func test_loadAchievements_withAsync_textShouldBeSet() throws {
        makeViewAppear()
        
        let achievementsSet = expectation(description: "achievements set")
        
        client.testCompletionHandler = {
            achievementsSet.fulfill()
        }
        
        client.dataTaskArgsCompletionHandler.first?(try achievementsValidData(), nil, nil)
        
        waitForExpectations(timeout: 0.01)
        
        XCTAssertEqual(sut.achievementsLabel.text, "Вы выиграли 0 игр!")
    }
    
    func test_loadAchievementsError_withAsync_textShouldBeSet() throws {
        makeViewAppear()
        
        let achievementsSet = expectation(description: "achievements set")
        
        client.testCompletionHandler = {
            achievementsSet.fulfill()
        }
        
        client.dataTaskArgsCompletionHandler.first?(nil, nil, TestError(message: "DUMMY"))
        
        waitForExpectations(timeout: 0.01)
        
        XCTAssertEqual(sut.achievementsLabel.text, "Произошла ошибка при получении данных")
    }
    
    @MainActor func test_loadAchievementsError_withAsync_shouldShowAlert() throws {
        makeViewAppear()
        let achievementsSet = expectation(description: "achievements set")
        client.testCompletionHandler = {
            achievementsSet.fulfill()
        }
        client.dataTaskArgsCompletionHandler.first?(nil, nil, TestError(message: "DUMMY"))
        
        waitForExpectations(timeout: 0.01)
        
        validateAlert(title: "Не удалось загрузить данные", message: "DUMMY")
    }
    
    // MARK: Buttons
    
    func test_tapCreateLobbyButton_shouldOpenLobbyCreator() {
        tap(sut.createLobbyButton)
        executeRunLoop()
        
        XCTAssertEqual(coordinator.viewControllers.count, 2)
        
        let pushedVC = coordinator.viewControllers.last
        
        guard pushedVC is CreateLobbyViewController else {
            XCTFail("Expected CreateLobbyViewController, but was \(String(describing: pushedVC))")
            return
        }
    }
    
    func test_tapJoinLobbyButton_shouldOpenJoinLobby() {
        tap(sut.enterGameButton)
        executeRunLoop()
        
        XCTAssertEqual(coordinator.viewControllers.count, 2)
        
        let pushedVC = coordinator.viewControllers.last
        
        guard pushedVC is EnterCodeViewController else {
            XCTFail("Expected CreateLobbyViewController, but was \(String(describing: pushedVC))")
            return
        }
    }
    
    @MainActor private func validateAlert(title: String?, message: String?, file: StaticString = #file, line: UInt = #line) {
        alertVerifier.verify(
            title: title,
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
    
    private func makeViewAppear() {
        sut.beginAppearanceTransition(true, animated: true)
        sut.endAppearanceTransition()
    }
    
    private func achievementsValidData() throws -> Data {
        let score = 0
        let encoder = JSONEncoder()
        return try encoder.encode(score)
    }
}
