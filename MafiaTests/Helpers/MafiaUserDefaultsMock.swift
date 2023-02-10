@testable import Mafia

class MafiaUserDefaultsMock: MafiaUserDefaultsProtocol {
    var storage: [String: Codable] = [:]
    
    func set(_ value: Codable, forKey key: String) throws {
        storage[key] = value
    }
    
    func object<T: Codable>(forKey key: String, type: T.Type) throws -> T? {
        if let item = storage[key] as? T {
            return item
        }
        return nil
    }
    
    func removeObject(forKey key: String) {
        storage.removeValue(forKey: key)
    }
}
