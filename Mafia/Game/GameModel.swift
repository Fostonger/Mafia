import Dispatch
import Foundation

enum GameStage: Int {
    case townAwaken = 0
    case mafia = 1
    case doctor
    case comissar
}

enum Role: Int {
    case civilian = 0
    case mafia = 1
    case doctor
    case comissar
}

struct UsersStatus: Codable {
    let alive: [User]
    let dead: [User]
}

let qwwqqw = [User(id: 0, nickname: "BOBA"), User(id: 1, nickname: "BIBA")]

class GameModel: AsyncState<GameModel.State, GameModel.State.Update> {
    let gameId: GameID
    
    init(gameId: GameID) {
        self.gameId = gameId
        
        super.init(
            state: .init(aliveUsers: qwwqqw, deadUsers: [], stage: .townAwaken, role: nil),
            queue: DispatchQueue(label: "\(GameModel.self)", attributes: [])
        )
        
//        URLSession.shared.request(apiRequest: .getPlayersStatuses(gameId: gameId),
//                                  expecting: UsersStatus.self) { [weak self] result in
//            switch result {
//            case .success(let state):
//                self?.perform(update: .usersStateUpdate(alive: state.alive, dead: state.dead))
//            case .failure(let failure):
//                self?.perform(update: .error(failure))
//            }
//        }
    }
    
    func perform(update: State.Update) {
        process(curry(process)(update))
    }
    
    private func process(update: State.Update, state: State) -> (State, State.Update) {
        let newState: State
        switch update {
        case .usersStateUpdate(let alive, let dead):
            newState = State(
                aliveUsers: alive,
                deadUsers: dead,
                stage: current.stage, role: current.role
            )
        case .gameStageChange(let stage):
            newState = State(
                aliveUsers: current.aliveUsers,
                deadUsers: current.deadUsers,
                stage: stage,
                role: current.role
            )
        case .error(_):
            newState = current
        case .setRole(role: let role):
            newState = State(
                aliveUsers: current.aliveUsers,
                deadUsers: current.deadUsers,
                stage: current.stage,
                role: role
            )
        }
        return (newState, update)
    }
}

extension GameModel {
    struct State {
        let aliveUsers: [User]
        let deadUsers: [User]
        let stage: GameStage
        let role: Role?
    }
}

extension GameModel.State {
    enum Update {
        case usersStateUpdate(alive: [User], dead: [User])
        case gameStageChange(stage: GameStage)
        case setRole(role: Role)
        case error(Error)
    }
}

extension GameModel {
    func longpoll() {
        URLSession.shared.request(apiRequest: .getGameStage(gameId: gameId),
                                  expecting: Int.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let stageNumber):
                    self?.perform(update: .gameStageChange(stage: GameStage(rawValue: stageNumber)!))
                    self?.longpoll()
                case .failure(let failure):
                    self?.perform(update: .error(failure))
                }
            }
        }
    }
}
