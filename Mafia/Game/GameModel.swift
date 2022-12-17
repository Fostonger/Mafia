import Dispatch

final class GameModel: AsyncState<GameModel.State, GameModel.State.Update> {
    let gameId: GameID
    
    init(gameId: GameID, aliveUsers: [User]) {
        self.gameId = gameId
        
        super.init(
            state: .init(aliveUsers: aliveUsers),
            queue: DispatchQueue(label: "\(GameModel.self)", attributes: [])
        )
    }
}

extension GameModel {
    struct State {
        let aliveUsers: [User]
    }
}

extension GameModel.State {
    enum Update {
        case pending
        case townIsAwaken
        case userIsAwaken
        case sleeping
        case roleActing(target: UserId)
    }
}
