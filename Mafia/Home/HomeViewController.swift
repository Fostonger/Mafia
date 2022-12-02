//
//  HomeViewController.swift
//  Mafia
//
//  Created by Булат Мусин on 02.12.2022.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.text = "Mafia Online"
        return label
    }()
    
    private let externalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 32
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let enterGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enter game", for: .normal)
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let createLobbyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create lobby", for: .normal)
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let internalStackView: UIStackView = {
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
        view.backgroundColor = .systemBackground
        setupViews()
        makeConstraints()
    }
    
    private func setupViews() {
        view.addSubview(externalStackView)
        externalStackView.addArrangedSubview(titleLabel)
        externalStackView.addArrangedSubview(internalStackView)
        internalStackView.addArrangedSubview(enterGameButton)
        internalStackView.addArrangedSubview(createLobbyButton)
    }
    
    private func makeConstraints() {
        externalStackView.snp.makeConstraints { make in
            make.top.equalTo(view.snp_topMargin)
            make.horizontalEdges.equalToSuperview()
        }
        internalStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        enterGameButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        createLobbyButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
    
    private func setupButtons() {
        enterGameButton.addTarget(self, action: #selector(enterGameButtonTapped), for: .touchUpInside)
    }
    
    @objc func enterGameButtonTapped() {
        guard let coordinator = navigationController as? LobbiesCoordinator else {
            return
        }
        coordinator.openEnterCodeView()
    }
}
