import UIKit

protocol LobbiesCoordinator {
    func openEnterCodeView()
    func joinLobby(with code: Int)
    func createLobby(amountOfPlayers: Int)
    func openLobbyCreationView()
    func getAchievements(completion: @escaping(Result<Int, Error>) -> Void)
}

class HomeCoordinator: UINavigationController {
    let model: HomeModel
    var user: User
    
    private init(user: User, model: HomeModel) {
        self.user = user
        self.model = model
        super.init(nibName: nil, bundle: nil)
        let homeView = HomeViewController()
        setViewControllers([homeView], animated: true)
    }
    
    static func make(user: User) -> HomeCoordinator {
        let model = HomeModel(userId: user.id)
        let coordinator = HomeCoordinator(user: user, model: model)
        return coordinator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeCoordinator: LobbiesCoordinator {
    func getAchievements(completion: @escaping (Result<Int, Error>) -> Void) {
        model.loadAchievements(of: user.id, completion: completion)
    }
    
    func openEnterCodeView() {
        let enterCodeViewController = EnterCodeViewController()
        pushViewController(enterCodeViewController, animated: true)
    }
    
    func openLobbyCreationView() {
        let lobbyCreationVC = CreateLobbyViewController()
        pushViewController(lobbyCreationVC, animated: true)
    }
    
    func joinLobby(with gameId: Int) {
        showHUD()
        model.joinLobby(with: gameId) { [weak self] result in
            guard let self = self else {
                return
            }
            self.hideHUD()
            switch result {
            case .success(_):
                let gameScreen = self.openGameScreen(gameId: gameId)
                self.present(gameScreen, animated: true)
            case .failure(let error):
                self.presentAlert(title: "Не удалось подключиться к лобби", message: error.localizedDescription)
            }
        }
    }
    
    func createLobby(amountOfPlayers: Int) {
        URLSession.shared.requestOneElement(
            apiRequest: .createLobby(amountOfPlayers: amountOfPlayers, userId: user.id),
            expecting: Int.self
        ) { [weak self] result in
            guard let self = self else {
                return
            }
            self.hideHUD()
            switch result {
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            case .success(let gameId):
                self.joinLobby(with: gameId)
                self.user.isAdmin = true
            }
        }
    }
    
    func openGameScreen(gameId: GameID) -> GameCoordinator {
        let coordinator = GameCoordinator.make(user: user, gameId: gameId)
        coordinator.modalPresentationStyle = .fullScreen
        return coordinator
    }
}
