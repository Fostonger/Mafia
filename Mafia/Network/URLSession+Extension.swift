import Foundation

enum APIError: Error {
    case invalidRequest
    case invalidData
}

extension URLSession {
    func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> ()
    ) {
        
        guard let url = url else {
            completion(.failure(APIError.invalidRequest))
            return
        }
        
        let task = dataTask(with: url) { data, _, error in
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.invalidData))
                }
            }
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
            
        }
        
        task.resume()
    }
}
