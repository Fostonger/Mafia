import Dispatch
import Foundation

enum GameStage: Int {
    case pending = -1
    case townAwaken = 0
    case mafia = 1
    case doctor
    case comissar
    case mafiaWon
    case citizenWon
    
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
        case .mafiaWon:
            return "Победила мафия"
        case .citizenWon:
            return "Победили мирные жители"
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
    let user: User
    let client: MafiaAPIClient
    
    init(gameId: GameID, user: User, client: MafiaAPIClient) {
        self.gameId = gameId
        self.user = user
        self.client = client
        
        super.init(
            state: .init(aliveUsers: [], deadUsers: [], stage: .pending, comissarIsRight: false, role: nil),
            queue: DispatchQueue(label: "\(GameModel.self)", attributes: [])
        ) { state in
            return (state, .gameStageChange(stage: .pending))
        }
        
        client.requestOneElement(
            apiRequest: .getRole(lobbyId: gameId, userId: user.id),
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
        var newUpdate = update
        switch newUpdate {
        case .usersStateUpdate(let alive, let dead, let comissarIsCorrect):
            newState = State(
                aliveUsers: alive,
                deadUsers: dead,
                stage: current.stage,
                comissarIsRight: comissarIsCorrect,
                role: current.role
            )
            newUpdate = State.Update.usersStateUpdate(
                alive: alive,
                dead: dead.filter({ user in
                    !current.deadUsers.contains(where: { $0.id == user.id })
                }),
                comissarIsCorrect: comissarIsCorrect
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
        return (newState, newUpdate)
    }
}

extension GameModel {
    func makeAction(victimId: UserId) {
        client.requestOneElement(
            apiRequest: .chooseVictim(
                gameId: gameId,
                victimId: victimId,
                userId: current.stage != .townAwaken ? user.id : nil
            ),
            expecting: Int.self
        ) { [weak self] result in
            switch result {
            case .success(let stage):
                if GameStage(rawValue: stage) == .townAwaken || GameStage(rawValue: stage) == .mafia { self?.getUsersStatus() }
                self?.perform(update: .gameStageChange(stage: GameStage(rawValue: stage) ?? .townAwaken))
            case .failure(let error):
                self?.perform(update: .error(error))
            }
        }
    }
    
    func getGameStage() {
        client.requestOneElement(
            apiRequest: .getGameStage(gameId: gameId),
            expecting: Int.self
        ) { [weak self] result in
            switch result {
            case .success(let stage):
                if GameStage(rawValue: stage) == .townAwaken || GameStage(rawValue: stage) == .mafia { self?.getUsersStatus() }
                self?.perform(update: .gameStageChange(stage: GameStage(rawValue: stage) ?? .townAwaken))
            case .failure(let error):
                self?.perform(update: .error(error))
            }
        }
    }
    
    func getUsersStatus() {
        client.request(
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
