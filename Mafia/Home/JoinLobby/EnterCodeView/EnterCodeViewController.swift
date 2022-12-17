//
//  EnterCodeViewController.swift
//  Mafia
//
//  Created by Булат Мусин on 03.12.2022.
//

import UIKit

class EnterCodeViewController: UIViewController {
    private let codeTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Lobby Code"
        textField.backgroundColor = .secondarySystemBackground
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.contentMode = .center
        return textField
    }()
    
    private let joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join", for: .normal)
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.isEnabled = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        stackView.addArrangedSubview(codeTextField)
        stackView.addArrangedSubview(joinButton)
        codeTextField.delegate = self
    }
    
    private func setupConstraints() {
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.snp_topMargin).inset(32)
        }
        codeTextField.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(200)
        }
        joinButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(90)
        }
    }
    
    private func setupButtons() {
        joinButton.addTarget(self, action: #selector(joinByCode), for: .touchUpInside)
    }
    
    @objc func joinByCode() {
        guard let coordinator = navigationController as? LobbiesCoordinator,
              let code = codeTextField.text else {
            return
        }
        coordinator.joinLobby(with: code)
    }

}

extension EnterCodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        joinButton.isEnabled = (textField.text?.count ?? 0) + string.count - range.length > 0
        return true
    }
}
