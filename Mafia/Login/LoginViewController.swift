//
//  LoginController.swift
//  Mafia
//
//  Created by Булат Мусин on 19.10.2022.
//

import UIKit
import SnapKit

class LoginViewModel {
    let coordinator: FirstPageCoordinable
    
    let client: MafiaAPIClient
    let defaults: MafiaUserDefaultsProtocol
    
    init(client: MafiaAPIClient, defaults: MafiaUserDefaultsProtocol, delegate: FirstPageCoordinable) {
        self.client = client
        self.defaults = defaults
        self.coordinator = delegate
    }
    
    func logIn(with credentials: LoginCredentials, completion: @escaping(Result<User, Error>) -> Void) {
        client.requestOneElement(
            apiRequest: .login(username: credentials.nickname, password: credentials.password),
            expecting: Int.self
        ) { [weak self] result in
            switch result {
            case .success(let userId):
                let user = User(id: userId, username: credentials.nickname)
                try! self?.defaults.set(user, forKey: "User")
                self?.coordinator.openHomeView(with: user)
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}

class LoginViewController: UIViewController {
    
    static func make(client: MafiaAPIClient, defaults: MafiaUserDefaultsProtocol, delegate: FirstPageCoordinable) -> LoginViewController {
        let model = LoginViewModel(client: client, defaults: defaults, delegate: delegate)
        return .init(model: model)
    }
    
    private init(model: LoginViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let model: LoginViewModel
    
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
        textField.font = .podkovaFont(type: .regular)
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
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .podkovaFont(type: .regular)
        button.isEnabled = false
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.layer.borderColor = UIColor.systemPink.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .podkovaFont(type: .regular)
        button.isEnabled = true
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        loginStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(loginButton)
        buttonsStackView.addArrangedSubview(registerButton)
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
        registerButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(90)
        }
    }
    
    private func setupButtons() {
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerAction), for: .touchUpInside)
    }
    
    @objc private func loginAction() {
        guard let nickname = nicknameTextField.text, let password = passwordTextField.text else {
            fatalError("Credentials are nil")
        }
        loginButton.isEnabled = false
        let credentials = LoginCredentials(nickname: nickname, password: password.MD5)
        model.logIn(with: credentials) { [weak self] result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                self?.presentAlert(title: "Ошибка при входе", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func registerAction() {
        let registerCV = RegisterViewController.make(client: model.client, defaults: model.defaults, delegate: model.coordinator)
        navigationController?.pushViewController(registerCV, animated: true)
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
    
    static func chechIfTextFieldsAreNotEmpty(currentTextField: UITextField, range: NSRange, string: String, secondTextField: UITextField) -> Bool{
        return (currentTextField.text?.count ?? 0) + string.count - range.length > 0 && !secondTextField.text.isNilOrEmpty
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let secondTextField = textField == nicknameTextField ? passwordTextField : nicknameTextField
        loginButton.isEnabled = Self.chechIfTextFieldsAreNotEmpty(currentTextField: textField,
                                                             range: range,
                                                             string: string,
                                                             secondTextField: secondTextField)
        return true
    }
}
