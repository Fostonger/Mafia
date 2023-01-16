//
//  CreateLobbyViewController.swift
//  Mafia
//
//  Created by Булат Мусин on 22.12.2022.
//

import UIKit

class CreateLobbyViewController: UIViewController {
    private let codeTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Amount of players"
        textField.backgroundColor = .secondarySystemBackground
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
        textField.contentMode = .center
        textField.font = .podkovaFont(type: .regular)
        return textField
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .podkovaFont(type: .regular)
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
        setupButtons()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        stackView.addArrangedSubview(codeTextField)
        stackView.addArrangedSubview(createButton)
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
        createButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(90)
        }
    }
    
    private func setupButtons() {
        createButton.addTarget(self, action: #selector(createLobby), for: .touchUpInside)
    }
    
    @objc func createLobby() {
        guard let coordinator = navigationController as? LobbiesCoordinator,
              let stringCode = codeTextField.text,
              let code = Int(stringCode) else {
            return
        }
        coordinator.createLobby(amountOfPlayers: code)
    }

}

extension CreateLobbyViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        createButton.isEnabled = (textField.text?.count ?? 0) + string.count - range.length > 0
        return true
    }
}

