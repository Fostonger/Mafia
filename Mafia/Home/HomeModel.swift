import Foundation

typealias GameID = Int

protocol LobbyNetworkModel {
    func joinLobby(with code: String, completion: @escaping(Result<GameID, Error>) -> ())
}

class HomeModel: LobbyNetworkModel {
    let client: APIClient
    
    init(client: APIClient) {
        self.client = client
    }
    
    func joinLobby(with code: String, completion: @escaping(Result<GameID, Error>) -> ()) {
        // TODO: Send code to server, get GameID, send it back to home coordinator
        
        completion(.success(0))
    }
    
}
