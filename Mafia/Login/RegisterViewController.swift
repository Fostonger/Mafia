import UIKit
import SnapKit

class RegisterViewModel {
    private let delegate: FirstPageCoordinable
    
    private let client: MafiaAPIClient
    private let defaults: MafiaUserDefaultsProtocol
    
    init(client: MafiaAPIClient, defaults: MafiaUserDefaultsProtocol, delegate: FirstPageCoordinable) {
        self.client = client
        self.defaults = defaults
        self.delegate = delegate
    }
    
    func register(with credentials: LoginCredentials, completion: @escaping(Result<User, Error>) -> Void) {
        client.requestOneElement(
            apiRequest: .register(username: credentials.nickname, password: credentials.password),
            expecting: Int.self
        ) { [weak self] result in
            switch result {
            case .success(let userId):
                let user = User(id: userId, username: credentials.nickname)
                try! self?.defaults.set(user, forKey: "User")
                self?.delegate.openHomeView(with: user)
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}

class RegisterViewController: UIViewController {
    
    static func make(client: MafiaAPIClient, defaults: MafiaUserDefaultsProtocol, delegate: FirstPageCoordinable) -> RegisterViewController {
        let model = RegisterViewModel(client: client, defaults: defaults, delegate: delegate)
        return .init(model: model)
    }
    
    private init(model: RegisterViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nicknameTextField: UITextField = {
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
    
    let passwordTextField: UITextField = {
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
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.titleLabel?.font = .podkovaFont(type: .regular)
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
    
    private let model: RegisterViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nicknameTextField.delegate = self
        passwordTextField.delegate = self
        view.backgroundColor = .systemBackground
        setupViews()
        setupConstraints()
        setupButtons()
    }
    
    private func setupViews() {
        view.addSubview(loginStackView)
        loginStackView.addArrangedSubview(loginView)
        loginStackView.addArrangedSubview(registerButton)
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
        registerButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(90)
        }
    }
    
    private func setupButtons() {
        registerButton.addTarget(self, action: #selector(registerAction), for: .touchUpInside)
    }
    
    @objc private func registerAction() {
        guard let nickname = nicknameTextField.text, let password = passwordTextField.text else {
            return
        }
        registerButton.isEnabled = false
        let credentials = LoginCredentials(nickname: nickname, password: password.MD5)
        model.register(with: credentials) { [weak self] response in
            switch response {
            case .success(_):
                break
            case .failure(let error):
                self?.presentAlert(title: "Ошибка при регистрации", message: error.localizedDescription)
                self?.nicknameTextField.text = ""
                self?.passwordTextField.text = ""
                self?.registerButton.isEnabled = true
            }
        }
    }

}

extension RegisterViewController: UITextFieldDelegate {
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
        registerButton.isEnabled = (textField.text?.count ?? 0) + string.count - range.length > 0
                                && !secondTextField.text.isNilOrEmpty
        return true
    }
}
