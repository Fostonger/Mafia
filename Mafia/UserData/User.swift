typealias UserId = Int

struct User: Codable {
    let id: UserId
    let username: String
    var isAdmin: Bool? = nil
}
