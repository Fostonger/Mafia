import Dispatch
import Foundation

enum GameStage: Int {
    case pending = -1
    case townAwaken = 0
    case mafia = 1
    case doctor
    case comissar
    
    var localizedStage: String {
        switch self {
        case .townAwaken:
            return "Город просыпается"
        case .mafia:
            return "Ход мафии"
        case .doctor:
            return "Ход доктора"
        case .comissar:
            return "Ход комиссара"
        case .pending:
            return "Ожидаем игроков"
        }
    }
}

enum Role: Int {
    case civilian = 0
    case mafia = 1
    case doctor
    case comissar
    
    var localizedName: String {
        switch self {
        case .civilian:
            return "Мирный житель 👨"
        case .mafia:
            return "Мафия 😎"
        case .doctor:
            return "Доктор 👨‍⚕️"
        case .comissar:
            return "Комиссар 👮‍♀️"
        }
    }
}

private struct UsersStatus: Codable {
    let alive: [User]
    let dead: [User]
    let comissarIsCorrect: Bool
}

class GameModel: AsyncState<GameModel.State, GameModel.State.Update> {
    let gameId: GameID
    let userId: UserId
    
    init(gameId: GameID, userId: UserId) {
        self.gameId = gameId
        self.userId = userId
        
        super.init(
            state: .init(aliveUsers: [], deadUsers: [], stage: .pending, comissarIsRight: false, role: nil),
            queue: DispatchQueue(label: "\(GameModel.self)", attributes: [])
        ) { state in
            return (state, .gameStageChange(stage: .pending))
        }
        
        URLSession.shared.requestOneElement(
            apiRequest: .getRole(lobbyId: gameId, userId: userId),
            expecting: Int.self
        ) { [weak self] result in
            switch result {
            case .success(let roleInt):
                self?.perform(update: .setRole(role: Role(rawValue: roleInt) ?? .civilian))
            case .failure(let failure):
                self?.perform(update: .error(failure))
            }
        }
    }
    
    func perform(update: State.Update) {
        process(curry(process)(update))
    }
    
    private func process(update: State.Update, state: State) -> (State, State.Update) {
        let newState: State
        switch update {
        case .usersStateUpdate(let alive, let dead, let comissarIsCorrect):
            newState = State(
                aliveUsers: alive,
                deadUsers: dead,
                stage: current.stage,
                comissarIsRight: comissarIsCorrect,
                role: current.role
            )
        case .gameStageChange(let stage):
            newState = State(
                aliveUsers: current.aliveUsers,
                deadUsers: current.deadUsers,
                stage: stage,
                comissarIsRight: stage == .townAwaken ? current.comissarIsRight : false,
                role: current.role
            )
        case .error(_):
            newState = current
        case .setRole(role: let role):
            newState = State(
                aliveUsers: current.aliveUsers,
                deadUsers: current.deadUsers,
                stage: current.stage,
                comissarIsRight: false,
                role: role
            )
        }
        return (newState, update)
    }
}

extension GameModel {
    func makeAction(victimId: UserId) {
        URLSession.shared.requestOneElement(
            apiRequest: .chooseVictim(
                gameId: gameId,
                victimId: victimId,
                userId: current.stage != .townAwaken ? userId : nil
            ),
            expecting: Int.self
        ) { [weak self] result in
            switch result {
            case .success(let stage):
                self?.perform(update: .gameStageChange(stage: GameStage(rawValue: stage) ?? .townAwaken))
            case .failure(let error):
                self?.perform(update: .error(error))
            }
        }
    }
    
    func getGameStage() {
        URLSession.shared.requestOneElement(
            apiRequest: .getGameStage(gameId: gameId),
            expecting: Int.self
        ) { [weak self] result in
            switch result {
            case .success(let stage):
                if GameStage(rawValue: stage) == .townAwaken { self?.getUsersStatus() }
                self?.perform(update: .gameStageChange(stage: GameStage(rawValue: stage) ?? .townAwaken))
            case .failure(let error):
                self?.perform(update: .error(error))
            }
        }
    }
    
    func getUsersStatus() {
        URLSession.shared.requestOneElement(
            apiRequest: .getPlayersStatuses(gameId: gameId),
            expecting: UsersStatus.self
        ) { [weak self] result in
            switch result {
            case .success(let status):
                self?.perform(
                    update: .usersStateUpdate(
                        alive: status.alive,
                        dead: status.dead,
                        comissarIsCorrect: status.comissarIsCorrect
                    )
                )
            case .failure(let error):
                self?.perform(update: .error(error))
            }
        }
    }
}

extension GameModel {
    struct State {
        let aliveUsers: [User]
        let deadUsers: [User]
        let stage: GameStage
        let comissarIsRight: Bool
        let role: Role?
    }
}

extension GameModel.State {
    enum Update {
        case usersStateUpdate(alive: [User], dead: [User], comissarIsCorrect: Bool)
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
