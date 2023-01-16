import Foundation

typealias GameID = Int

protocol LobbyNetworkModel {
    func joinLobby(with code: Int, completion: @escaping(Result<GameID, Error>) -> ())
}

class HomeModel: LobbyNetworkModel {
    private let userId: UserId
    let client: MafiaAPIClient
    
    init(userId: UserId, client: MafiaAPIClient) {
        self.userId = userId
        self.client = client
    }
    
    func joinLobby(with code: Int, completion: @escaping(Result<GameID, Error>) -> ()) {
        client.requestOneElement(
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
    
    func createLobby(playersCount: Int, completion: @escaping(Result<GameID, Error>) -> Void) {
        client.requestOneElement(
            apiRequest: .createLobby(amountOfPlayers: playersCount, userId: userId),
            expecting: Int.self,
            completion: completion
        )
    }
    
    func loadAchievements(of userId: UserId, completion: @escaping(Result<Int, Error>) -> Void) {
        client.requestOneElement(
            apiRequest: .getAchievements(userId: userId),
            expecting: Int.self,
            completion: completion
        )
    }
}
