import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String? = nil, preferredStyle: UIAlertController.Style = .alert, actions: (()->([UIAlertAction]))? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        _ = actions?().map(alert.addAction)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.preferredAction = okAction
        self.present(alert, animated: true)
    }
}
