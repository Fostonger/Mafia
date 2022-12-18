typealias UserId = Int

struct User: Codable {
    let id: UserId
    let nickname: String
}
