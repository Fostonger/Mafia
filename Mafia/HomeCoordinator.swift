import UIKit

protocol LobbiesCoordinator {
    func openEnterCodeView()
    func joinLobby(with code: String)
    func createLobby()
}

class HomeCoordinator: UINavigationController {
    let model: HomeModel
    let user: User
    
    private init(user: User, model: HomeModel) {
        self.user = user
        self.model = model
        super.init(nibName: nil, bundle: nil)
        let homeView = HomeViewController()
        setViewControllers([homeView], animated: true)
    }
    
    static func make(user: User) -> HomeCoordinator {
        let model = HomeModel()
        let coordinator = HomeCoordinator(user: user, model: model)
        return coordinator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeCoordinator: LobbiesCoordinator {
    func openEnterCodeView() {
        let enterCodeViewController = EnterCodeViewController()
        pushViewController(enterCodeViewController, animated: true)
    }
    
    func joinLobby(with code: String) {
        model.joinLobby(with: code) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let gameId):
                let gameScreen = self.openGameScreen(gameId: gameId)
                self.present(gameScreen, animated: true)
            case .failure(let error):
                self.presentAlert(title: "Не удалось подключиться к лобби", message: error.localizedDescription)
            }
        }
    }
    
    func createLobby() {
        URLSession.shared.request(
            apiRequest: .createLobby(userId: user.id),
            expecting: JustString.self
        ) { result in
            switch result {
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            case .success(let srting):
                print("success \(srting)")
            }
        }
        let gameScreen = openGameScreen(gameId: 12)
        gameScreen.modalPresentationStyle = .fullScreen
        present(gameScreen, animated: true)
    }
    
    func openGameScreen(gameId: GameID) -> GameCoordinator {
        let coordinator = GameCoordinator.make(user: user, gameId: gameId)
        return coordinator
    }
}

struct JustString: Codable {
    let hello: String
}
