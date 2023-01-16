import UIKit
import SnapKit

class CoverViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .podkovaFont(size: 30, type: .semiBold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .podkovaFont(size: 18, type: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let titleBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var queue = Queue<(() -> Void)>()
    private var duration = 1.0
    private var waitingDispatchItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let action = queue.dequeue() else {
            print("Set at least one setTitle function with enqueue function to show CoverViewController")
            return
        }
        action()
        self.appearingAnimation()
    }
    
    func enqueue(action: @escaping() -> Void) {
        queue.enqueue(element: action)
    }
    
    func setTitle(title: String, message: String? = nil, withDuration duration: Double = 1) {
        titleLabel.text = title
        messageLabel.text = message
        self.duration = duration
        removeConstraints()
        setupViews()
    }
    
    func hidePresentingLabel() {
        waitingDispatchItem?.perform()
        waitingDispatchItem?.cancel()
    }
    
    private func removeConstraints() {
        titleBackground.snp.removeConstraints()
        titleLabel.snp.removeConstraints()
        messageLabel.snp.removeConstraints()
    }
    
    private func setupViews() {
        view.addSubview(titleBackground)
        titleBackground.addSubview(titleLabel)
        titleBackground.addSubview(messageLabel)
        
        titleBackground.snp.makeConstraints { make in
            make.centerY.equalTo(view.bounds.height + 100)
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(8)
            make.top.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
        
        messageLabel.snp.makeConstraints {make in
            make.horizontalEdges.equalTo(titleLabel.snp.horizontalEdges)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(messageLabel.text != nil ? 8 : 0)
        }
    }
    
    private func appearingAnimation() {
        DispatchQueue.main.async {
            self.titleBackground.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.horizontalEdges.equalToSuperview().inset(12)
            }
            self.view.backgroundColor = .black.withAlphaComponent(0)
            
            self.titleLabel.snp.remakeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(8)
                make.top.equalToSuperview().inset(8)
                make.height.equalTo(40)
            }
            
            self.messageLabel.snp.remakeConstraints {make in
                make.horizontalEdges.equalTo(self.titleLabel.snp.horizontalEdges)
                make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
                make.bottom.equalToSuperview().inset(self.messageLabel.text != nil ? 8 : 0)
            }
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.view.layoutIfNeeded()
                    self.view.backgroundColor = .black.withAlphaComponent(0.3)
                }
            ) { _ in
                let newDispatchItem = DispatchWorkItem { [weak self] in
                    self?.disappearingAnimation(completion: {
                        if let completionBlock = self?.queue.dequeue() {
                            completionBlock()
                            DispatchQueue.main.async { self?.appearingAnimation() }
                        } else {
                            self?.dismiss(animated: false)
                        }
                    })
                }
                self.waitingDispatchItem = newDispatchItem
                DispatchQueue.main.asyncAfter(deadline: .now() + self.duration, execute: newDispatchItem)
            }
        }
    }
    
    private func disappearingAnimation(completion: @escaping() -> Void) {
        DispatchQueue.main.async {
            self.titleBackground.snp.remakeConstraints { make in
                make.centerY.equalTo(-100)
                make.horizontalEdges.equalToSuperview().inset(12)
            }
            self.view.backgroundColor = .black.withAlphaComponent(0.3)
            
            self.titleLabel.snp.remakeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(8)
                make.top.equalToSuperview().inset(8)
                make.height.equalTo(40)
            }
            
            self.messageLabel.snp.remakeConstraints {make in
                make.horizontalEdges.equalTo(self.titleLabel.snp.horizontalEdges)
                make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
                make.bottom.equalToSuperview().inset(self.messageLabel.text != nil ? 8 : 0)
            }
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.view.layoutIfNeeded()
                    self.view.backgroundColor = .black.withAlphaComponent(0)
                }
            ) { _ in
                completion()
            }
        }
    }
}
