//
//  LoginController.swift
//  Mafia
//
//  Created by Булат Мусин on 19.10.2022.
//

import UIKit
import SnapKit

class LoginViewModel {
    func logIn(with credentials: LoginCredentials, loginView: UIViewController) {
        let scene = UIApplication.shared.connectedScenes.first
        let query = {
            return [kSecClass as String: kSecClassInternetPassword,
                    kSecAttrAccount as String: credentials.nickname,
                    kSecValueData as String: credentials.password.data(using: .utf8)!]
        }
        guard let delegate = scene?.delegate as? SceneDelegate else {
            fatalError("there is no scene delegate")
        }
//        do {
//            try delegate.keyChainManager.addQuery(query)
//        } catch {
//            print(error)
//        }
        
        // TODO: Send request and get UserId and nickname of user
        let user = User(id: 0, nickname: "Fost")
        delegate.openHomeView(with: user)
    }
}

class LoginViewController: UIViewController {
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.tag = 0
        textField.returnKeyType = .next
        textField.placeholder = "Type in your nickname"
        textField.backgroundColor = .secondarySystemBackground
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.textContentType = .username
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.tag = 1
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.placeholder = "Type in your password"
        textField.backgroundColor = .secondarySystemBackground
        textField.textContentType = .password
        return textField
    }()
    
    private let loginView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.isEnabled = false
        return button
    }()
    
    private let loginStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let model = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nicknameTextField.delegate = self
        passwordTextField.delegate = self
        setupViews()
        setupConstraints()
        setupButtons()
    }
    
    private func setupViews() {
        view.addSubview(loginStackView)
        loginStackView.addArrangedSubview(loginView)
        loginStackView.addArrangedSubview(loginButton)
        loginView.addSubview(nicknameTextField)
        loginView.addSubview(passwordTextField)
    }
    
    private func setupConstraints() {
        
        loginStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.snp_topMargin).inset(32)
        }
        nicknameTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(40)
        }
        passwordTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(90)
        }
    }
    
    private func setupButtons() {
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
    }
    
    @objc private func loginAction() {
        guard let nickname = nicknameTextField.text, let password = passwordTextField.text else {
            fatalError("Credentials are nil")
        }
        loginButton.isEnabled = false
        let credentials = LoginCredentials(nickname: nickname, password: password)
        model.logIn(with: credentials, loginView: self)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let secondTextField = textField == nicknameTextField ? passwordTextField : nicknameTextField
        loginButton.isEnabled = (textField.text?.count ?? 0) + string.count - range.length > 0
                                && !secondTextField.text.isNilOrEmpty
        return true
    }
}
