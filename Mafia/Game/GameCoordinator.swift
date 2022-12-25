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
        model.notifier.subscribeWeak(self, type(of: self).process)
    }
    
    static func make(user: User, gameId: GameID) -> GameCoordinator {
        let model = GameModel(gameId: gameId, userId: user.id)
        return GameCoordinator(user: user, gameId: gameId, model: model)
    }
    
    private func process(update: GameModel.State.Update) {
        switch update {
        case .usersStateUpdate:
            break
        case .gameStageChange(stage: let stage):
            break
        case .setRole(role: let role):
            break
        case .error(_):
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
