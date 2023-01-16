import Foundation

fileprivate let host = "http://192.168.0.109:8000"

enum MafiaAPI {
    case login(username: String, password: String)
    case register(username: String, password: String)
    case createLobby(amountOfPlayers: Int, userId: UserId)
    case joinLobby(userId: UserId, code: Int)
    case changeLobbySettings(userId: UserId)
    case getPlayersStatuses(gameId: GameID)
    case chooseVictim(gameId: GameID, victimId: UserId, userId: UserId?)
    case getGameStage(gameId: GameID)
    case getRole(lobbyId: GameID, userId: UserId)
    case getAchievements(userId: UserId)
}

extension MafiaAPI {
    var request: URLRequest {
        var url = URLComponents(string: "\(host)\(path)")!
        url.queryItems = parameters
        print(url.url!)
        var request = URLRequest(url: url.url!)
        
        request.httpMethod = method
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 600
        return request
    }
    
    private var method: String {
        switch self {
        default:
            return "GET"
        }
    }
    
    private var path: String {
        switch self {
        case .login:
            return "/auth/"
        case .register:
            return "/reg/"
        case .createLobby:
            return "/create_game/"
        case .joinLobby:
            return "/connect/"
        case .changeLobbySettings:
            return ""
        case .getPlayersStatuses:
            return "/get_users_info/"
        case .chooseVictim:
            return "/change_stage/"
        case .getGameStage:
            return "/change_stage/"
        case .getRole:
            return "/get_role/"
        case .getAchievements:
            return "/get_achievements/"
        }
    }
    
    private var parameters: [URLQueryItem] {
        switch self {
        case .login(let username, let password):
            return [
                URLQueryItem(name:"username", value: username),
                URLQueryItem(name:"password", value: password)
            ]
        case .register(let username, let password):
            return [
                URLQueryItem(name:"username", value: username),
                URLQueryItem(name:"password", value: password)
            ]
        case .createLobby(let playersAmount, let userId):
            return [
                URLQueryItem(name:"number", value: String(playersAmount)),
                URLQueryItem(name:"myid", value: String(userId))
            ]
        case .joinLobby(let userId, let code):
            return [
                URLQueryItem(name:"myid", value: String(userId)),
                URLQueryItem(name:"roomid", value: String(code))
            ]
        case .changeLobbySettings(let userId):
            return [
                URLQueryItem(name:"userId", value: String(userId))
            ]
        case .getPlayersStatuses(let gameId):
            return [
                URLQueryItem(name:"roomid", value: String(gameId))
            ]
        case .chooseVictim(let gameId, let victimId, let userId):
            var params = [
                URLQueryItem(name:"roomid", value: String(gameId)),
                URLQueryItem(name:"userid", value: String(victimId))
            ]
            if let userId = userId {
                params.append(URLQueryItem(name:"myid", value: String(userId)))
            }
            return params
        case .getGameStage(let gameId):
            return [
                URLQueryItem(name:"roomid", value: String(gameId))
            ]
        case .getRole(lobbyId: let gameId, userId: let userId):
            return [
                URLQueryItem(name:"myid", value: String(userId)),
                URLQueryItem(name:"roomid", value: String(gameId))
            ]
        case .getAchievements(userId: let userId):
            return [
                URLQueryItem(name:"userid", value: String(userId))
            ]
        }
    }
}
