import Foundation

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        let q = self?.isEmpty ?? true
        return q
    }
}
