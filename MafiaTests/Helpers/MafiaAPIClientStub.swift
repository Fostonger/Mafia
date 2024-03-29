@testable import Mafia
import Foundation

class MafiaAPIClientStub: MafiaAPIClient {
    var dataTaskCallCount = 0
    var dataTaskArgsRequest: [MafiaAPI] = []
    var dataTaskArgsCompletionHandler:
            [(Data?, URLResponse?, Error?) -> Void] = []
    var testCompletionHandler: () -> () = { return }
    
    func request<T: Codable>(
        apiRequest: MafiaAPI,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> ()
    ) {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(apiRequest)
        dataTaskArgsCompletionHandler.append({ [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIError.invalidData))
                    }
                    self?.testCompletionHandler()
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(expecting, from: data)
                    completion(.success(result))
                    self?.testCompletionHandler()
                } catch {
                    completion(.failure(APIError.invalidType))
                    self?.testCompletionHandler()
                }
            }
        })
    }
    
    func requestOneElement<T>(
        apiRequest: MafiaAPI,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> ()
    ) where T: Codable {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(apiRequest)
        dataTaskArgsCompletionHandler.append({ [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIError.invalidData))
                    }
                    self?.testCompletionHandler()
                    return
                }
                guard let element = Int(String(data:data, encoding: .utf8)!) as? T else {
                    completion(.failure(APIError.invalidType))
                    self?.testCompletionHandler()
                    return
                }
                completion(.success(element))
                self?.testCompletionHandler()
            }
        })
    }
}
