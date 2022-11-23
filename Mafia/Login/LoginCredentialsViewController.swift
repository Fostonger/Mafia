//
//  LoginCredentialsViewController.swift
//  Mafia
//
//  Created by Булат Мусин on 19.10.2022.
//

import UIKit
import SnapKit

struct LoginCredentials {
    var nickname: String
    var password: String
}

class LoginCredentialsViewController: UIViewController {

    

}

extension LoginCredentialsViewController: UITextFieldDelegate {
    
}

protocol LoginCredentialsDelegate {
    func updateCredentials(with credentials: LoginCredentials)
}
