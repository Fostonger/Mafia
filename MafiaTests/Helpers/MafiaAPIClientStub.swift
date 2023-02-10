@testable import Mafia

class MafiaAPIClientStub: MafiaAPIClient {
    var dataTaskCallCount = 0
    var dataTaskArgsRequest: [MafiaAPI] = []
    var dataTaskArgsCompletionHandler:
            [(Result<Codable, Error>) -> ()] = []
    
    func request<T: Codable>(
        apiRequest: MafiaAPI,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> ()
    ) {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(apiRequest)
        dataTaskArgsCompletionHandler.append(completion as! (Result<Codable, Error>) -> ())
    }
    
    func requestOneElement<T: Codable>(
        apiRequest: MafiaAPI,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> ()
    ) {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(apiRequest)
        dataTaskArgsCompletionHandler.append(completion as! (Result<Codable, Error>) -> ())
    }
}
