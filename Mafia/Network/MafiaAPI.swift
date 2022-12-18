import Foundation

fileprivate let host = "http://172.20.10.3:8000"

enum MafiaAPI {
    case login(username: String, password: String)
    case register(username: String, password: String)
    case createLobby(userId: UserId)
    case joinLobby(userId: UserId, code: String)
    case changeLobbySettings(userId: UserId)
    case getPlayersStatuses(gameId: GameID)
    case chooseVictim(token: String, victimId: UserId, gameStage: GameStage)
    case getGameStage(gameId: GameID)
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
        return request
    }
    
    private var method: String {
        switch self {
        case .changeLobbySettings, .chooseVictim:
            return "POST"
        default:
            return "GET"
        }
    }
    
    private var path: String {
        switch self {
        case .login:
            return ""
        case .register:
            return ""
        case .createLobby:
            return ""
        case .joinLobby:
            return "/gamelogic"
        case .changeLobbySettings:
            return ""
        case .getPlayersStatuses:
            return ""
        case .chooseVictim:
            return ""
        case .getGameStage:
            return ""
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
        case .createLobby(let userId):
            return [
                URLQueryItem(name:"userId", value: String(userId))
            ]
        case .joinLobby(let userId, let code):
            return [
                URLQueryItem(name:"userId", value: String(userId)),
                URLQueryItem(name:"code", value: code)
            ]
        case .changeLobbySettings(let userId):
            return [
                URLQueryItem(name:"userId", value: String(userId))
            ]
        case .getPlayersStatuses(let gameId):
            return [
                URLQueryItem(name:"gameId", value: String(gameId))
            ]
        case .chooseVictim(let token, let victimId, let gameStage):
            return [
                URLQueryItem(name:"token", value: token),
                URLQueryItem(name:"victimId", value: String(victimId)),
                URLQueryItem(name:"gameStage", value: String(gameStage.rawValue))
            ]
        case .getGameStage(let gameId):
            return [
                URLQueryItem(name:"gameId", value: String(gameId))
            ]
        }
    }
}
