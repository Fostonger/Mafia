import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String, preferredStyle: UIAlertController.Style = .alert, actions: (()->([UIAlertAction]))?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        actions?().map(alert.addAction)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
