import Foundation

enum APIError: Error {
    case invalidRequest
    case invalidData
}

extension URLSession {
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
                    let result = try JSONDecoder().decode(expecting, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
