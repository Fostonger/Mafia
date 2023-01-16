import Foundation

enum APIError: Error {
    case invalidRequest
    case invalidData
    case invalidType
}

protocol MafiaAPIClient {
    func request<T: Codable>(apiRequest: MafiaAPI, expecting: T.Type, completion: @escaping (Result<T, Error>) -> ())
    func requestOneElement<T>(apiRequest: MafiaAPI, expecting: T.Type, completion: @escaping (Result<T, Error>) -> ())
}

extension URLSession: MafiaAPIClient {
    func request<T: Codable>(
        apiRequest: MafiaAPI,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> ()
    ) {
        let task = dataTask(with: apiRequest.request) { data, _, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIError.invalidData))
                    }
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(expecting, from: data)
                    print(result)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func requestOneElement<T>(
        apiRequest: MafiaAPI,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> ()
    ) {
        let task = dataTask(with: apiRequest.request) { data, _, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIError.invalidData))
                    }
                    return
                }
                print(String(data:data, encoding: .utf8))
                guard let element = Int(String(data:data, encoding: .utf8)!) as? T else {
                    completion(.failure(APIError.invalidType))
                    return
                }
                completion(.success(element))
            }
        }
        
        task.resume()
    }
}
