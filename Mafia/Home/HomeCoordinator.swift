import UIKit

protocol LobbiesCoordinator {
    func openEnterCodeView()
    func joinLobby(byCode: String)
    func createLobby()
}

class HomeCoordinator: UINavigationController {
    init() {
        let homeView = HomeViewController()
        setViewControllers([homeView], animated: true)
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
    
    func joinLobby(byCode: String) {
        <#code#>
    }
    
    func createLobby() {
        <#code#>
    }
}
