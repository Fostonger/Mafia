import UIKit

extension UIViewController {
    func parentImplementing(_ selector: Selector, with object: Any?) {
        var parent = next
        while parent != nil {
            if parent!.responds(to: selector) {
                parent?.perform(selector, with: object)
                return
            } else {
                parent = parent?.next
            }
        }
    }
    
    func parent<T>(implementing proto: T.Type) -> T? {
        return sequence(first: self, next: \.next)
            .dropFirst()
            .first { $0 is T } as? T
    }
}
