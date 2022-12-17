import UIKit

class GameCoordinator: UINavigationController {
    let user: User
    let gameId: GameID
    
    init(user: User, gameId: GameID) {
        self.user = user
        self.gameId = gameId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
