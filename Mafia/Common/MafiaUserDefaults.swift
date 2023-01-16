import Foundation

protocol MafiaUserDefaultsProtocol {
    func set(_ value: Codable, forKey key: String) throws
    func object<T: Codable>(forKey key: String, type: T.Type) throws -> T?
    func removeObject(forKey key: String)
}

final class MafiaUserDefaults: MafiaUserDefaultsProtocol {
    static let standard = MafiaUserDefaults()
    
    func set(_ value: Codable, forKey key: String) throws {
        let encoded = try JSONEncoder().encode(value)
        UserDefaults.standard.set(encoded, forKey: key)
    }
    
    func object<T: Codable>(forKey key: String, type: T.Type) throws -> T? {
        if let data = UserDefaults.standard.object(forKey: key) as? Data {
            let item = try JSONDecoder().decode(T.self, from: data)
            return item
        }
        return nil
    }
    
    func removeObject(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

