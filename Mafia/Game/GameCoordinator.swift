import UIKit

class GameCoordinator: UINavigationController {
    let user: User
    let gameId: GameID
    let model: GameModel
    
    init(user: User, gameId: GameID, model: GameModel) {
        self.user = user
        self.gameId = gameId
        self.model = model
        super.init(nibName: nil, bundle: nil)
        let deskVC = PlayDeskViewController(model: model)
        setViewControllers([deskVC], animated: true)
    }
    
    static func make(user: User, gameId: GameID) -> GameCoordinator {
        let model = GameModel(gameId: gameId)
        return GameCoordinator(user: user, gameId: gameId, model: model)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
