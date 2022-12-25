import Foundation

typealias GameID = Int

protocol LobbyNetworkModel {
    func joinLobby(with code: Int, completion: @escaping(Result<GameID, Error>) -> ())
}

class HomeModel: LobbyNetworkModel {
    let userId: UserId
    
    init(userId: UserId) {
        self.userId = userId
    }
    
    func joinLobby(with code: Int, completion: @escaping(Result<GameID, Error>) -> ()) {
        URLSession.shared.requestOneElement(
            apiRequest: .joinLobby(userId: userId, code: code),
            expecting: Int.self
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}
