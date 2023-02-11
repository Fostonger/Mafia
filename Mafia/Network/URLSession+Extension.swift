import Foundation

enum APIError: LocalizedError {
    case invalidRequest
    case invalidData
    case invalidType
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Неверный запрос"
        case .invalidData:
            return "Сервер вернул неверные данные"
        case .invalidType:
            return "Сервер вернул данные неверного типа"
        }
    }
}

protocol MafiaAPIClient {
    func request<T: Codable>(apiRequest: MafiaAPI, expecting: T.Type, completion: @escaping (Result<T, Error>) -> ())
    func requestOneElement<T: Codable>(apiRequest: MafiaAPI, expecting: T.Type, completion: @escaping (Result<T, Error>) -> ())
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
                    print(apiRequest.request)
                    print(result)
                    completion(.success(result))
                } catch {
                    completion(.failure(APIError.invalidType))
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
                guard let element = Int(String(data:data, encoding: .utf8)!) as? T else {
                    completion(.failure(APIError.invalidType))
                    return
                }
                print(apiRequest.request)
                print(element)
                completion(.success(element))
            }
        }
        
        task.resume()
    }
}
