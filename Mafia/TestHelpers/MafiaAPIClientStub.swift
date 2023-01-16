//
//  NetworkHelpers.swift
//  Mafia
//
//  Created by Булат Мусин on 16.01.2023.
//

import Foundation

enum TestStubError: Error {
    case dataIsOfDifferentType
}

class MafiaAPTClientStub: MafiaAPIClient {
    func request<T: Codable>(
        apiRequest: MafiaAPI,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> ()
    ) {
        let result = getResult(type: T.self)
        completion(result)
    }
    
    func requestOneElement<T: Codable>(
        apiRequest: MafiaAPI,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> ()
    ) {
        let result = getResult(type: T.self)
        completion(result)
    }
    
    private func getResult<T: Codable>(type: T.Type) -> Result<T, Error> {
        guard let data = stubbedData as? T else {
            if let error = stubbedError {
                return .failure(error)
            }
            return .failure(TestStubError.dataIsOfDifferentType)
        }
        return .success(data)
    }
    
    private let stubbedData: Codable?
    private let stubbedError: Error?
    
    public init(data: Codable? = nil, error: Error? = nil) {
        self.stubbedData = data
        self.stubbedError = error
    }
}
