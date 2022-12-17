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
    
    static func make(user: User, client: APIClient) -> HomeCoordinator {
        let model = HomeModel(client: client)
        let coordinator = HomeCoordinator(user: user, model: model)
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
                break
                self.present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>)
            case .failure(let error):
                self.presentAlert(title: "Не удалось подключиться к лобби", message: error.localizedDescription)
            }
        }
    }
    
    func createLobby() {
        
    }
}
