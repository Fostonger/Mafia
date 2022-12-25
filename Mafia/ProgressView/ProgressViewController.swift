import UIKit
import SnapKit

class ProgressVC: UIViewController {
    
    let loadingIndicator: ProgressView = {
        let progress = ProgressView(colors: [.red, .systemGreen, .systemBlue], lineWidth: 5)
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    let loadingBack: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = .systemGray6
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray.cgColor
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(loadingBack)
        loadingBack.addSubview(loadingIndicator)
        
        loadingBack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(75)
        }
        loadingIndicator.snp.makeConstraints{ make in
            make.center.equalToSuperview()
            make.size.equalTo(50)
        }
    }
    
    
    // MARK: - Properties
    
}
