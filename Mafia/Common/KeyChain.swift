import Foundation

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

final class MafiaKeyChain {
    func addServer(to query: @escaping() -> [String: Any]) -> () -> [String: Any]{
        return {
            var prevQuery = query()
            prevQuery[kSecAttrService as String] = "mafia.com"
            return prevQuery
        }
    }
    
    func addQuery(_ query: @escaping() -> [String: Any]) throws {
        try addItem(query: addServer(to: query)())
    }
    
    private func addItem(query: [String: Any]) throws {
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
}

