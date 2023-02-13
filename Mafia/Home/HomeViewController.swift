//
//  HomeViewController.swift
//  Mafia
//
//  Created by Булат Мусин on 02.12.2022.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .podkovaFont(size: 30, type: .semiBold)
        label.text = "МАФИЯ ОНЛАЙН"
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
    
    let enterGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти в игру", for: .normal)
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .podkovaFont(type: .regular)
        button.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }()
    
    let createLobbyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать игру", for: .normal)
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .podkovaFont(type: .regular)
        button.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return button
    }()
    
    let achievementsLabel: UILabel = {
        let label = UILabel()
        label.font = .podkovaFont(size: 16, type: .regular)
        label.text = "Подождите, загружаем данные..."
        label.textAlignment = .center
        return label
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
        setupButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadAchievements()
    }
    
    private func setupViews() {
        view.addSubview(externalStackView)
        externalStackView.addArrangedSubview(titleLabel)
        externalStackView.addArrangedSubview(internalStackView)
        externalStackView.addArrangedSubview(achievementsLabel)
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
            make.width.equalTo(150)
        }
        createLobbyButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(150)
        }
    }
    
    private func setupButtons() {
        enterGameButton.addTarget(self, action: #selector(enterGameButtonTapped), for: .touchUpInside)
        createLobbyButton.addTarget(self, action: #selector(createLobbyButtonTapped), for: .touchUpInside)
    }
    
    private func loadAchievements() {
        guard let coordinator = navigationController as? LobbiesCoordinator else {
            return
        }
        coordinator.getAchievements { [weak self] result in
            switch result {
            case .success(let winRate):
                self?.achievementsLabel.text = "Вы выиграли \(winRate) игр!"
            case .failure(let error):
                self?.presentAlert(title: "Не удалось загрузить данные", message: error.localizedDescription)
                self?.achievementsLabel.text = "Произошла ошибка при получении данных"
            }
        }
    }
    
    @objc func enterGameButtonTapped() {
        guard let coordinator = navigationController as? LobbiesCoordinator else {
            return
        }
        coordinator.openEnterCodeView()
    }
    
    @objc func createLobbyButtonTapped() {
        guard let coordinator = navigationController as? LobbiesCoordinator else {
            return
        }
        coordinator.openLobbyCreationView()
    }
}
