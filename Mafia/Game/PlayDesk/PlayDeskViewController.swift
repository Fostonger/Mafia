import UIKit

class PlayDeskViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    let model: GameModel
    let playersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 4)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    fileprivate var coverVCBaseProperty: CoverViewController? =  {
        let controller = CoverViewController()
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }()
    
    private var coverVC: CoverViewController {
        get {
            guard let coverVC = self.coverVCBaseProperty else {
                coverVCBaseProperty = CoverViewController()
                coverVCBaseProperty!.modalPresentationStyle = .overFullScreen
                return coverVCBaseProperty!
            }
            return coverVC
        }
    }
    
    // MARK: LOGIC
    
    init(model: GameModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        model.notifier.subscribeWeak(self, type(of: self).handle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func handle(update: GameModel.State.Update) {
        switch update {
        case .usersStateUpdate(_, let deadUsers, let comissarIsRight):
            handleUsersStatusUpdate(deadUsers: deadUsers, comissarIsRight: comissarIsRight)
        case .gameStageChange(let stage):
            stage |> newGameStageHandling
        case .setRole(let role):
            role |> presentRoleSetting
            model.getUsersStatus()
        case .error(let error):
            presentAlert(title: "Ошибка!", message: error.localizedDescription)
        }
    }
    
    private func presentRoleSetting(role: Role) {
        coverVC.clearQueue()
        coverVC.enqueue { [weak coverVC] in
            coverVC?.setTitle(title: "Ваша роль", message: role.localizedName, withDuration: 1)
        }
        model.perform(update: .gameStageChange(stage: .mafia))
        presentIfPossible()
    }
    
    private func newGameStageHandling(stage: GameStage) {
        if stage.rawValue > 3 {
            coverVC.enqueue { [weak coverVC] in
                coverVC?.setTitle(title: "Игра окончена", message: stage.localizedStage)
            }
            coverVC.enqueue { [weak self] in
                self?.dismiss(animated: true)
                self?.dismiss(animated: true)
            }
            presentIfPossible()
            return
        }
        
        let intStage = stage.rawValue
        let intRole = model.current.role?.rawValue ?? 0
        let isAsleep = !(intStage < 1 || intRole == intStage)
        let isDead = model.current.deadUsers.contains(where: { return $0.id == model.user.id })
        playersCollectionView.isUserInteractionEnabled = !(isAsleep && !isDead)
        coverVC.enqueue { [weak coverVC, weak self] in
            coverVC?.setTitle(
                title: stage.localizedStage,
                message: stage == .pending ? "Код игры: \(self!.model.gameId)" : nil,
                withDuration: (isAsleep || stage == .pending) ? 400 : 1
            )
        }
        presentIfPossible() // Скрываем лейбл прошлого хода
        if isAsleep {
            model.getGameStage()
        }
    }
    
    private func handleUsersStatusUpdate(deadUsers: [User], comissarIsRight: Bool) {
        playersCollectionView.reloadData()
        guard model.current.showDeaths else {
            return
        }
        let deadUsersNames = deadUsers.compactMap({ $0.username }).joined(separator: ", ")
        switch model.current.stage {
        case .townAwaken:
            coverVC.enqueue { [weak coverVC] in
                coverVC?.setTitle(
                    title: "Итоги ночи",
                    message:  """
                          Комиссар сделал \(comissarIsRight ? "правильный" : "неправильный") выбор
                          Этой ночью \(!deadUsersNames.isEmpty ? "убили: \(deadUsersNames)" : "никого не убили")
                          """,
                    withDuration: 3
                )
            }
            presentIfPossible()
        case .mafia:
            coverVC.enqueue { [weak coverVC] in
                coverVC?.setTitle(
                    title: "Итог голосования",
                    message:  """
                          В ходе голосования \(!deadUsersNames.isEmpty ? "убили: \(deadUsersNames)" : "никого не убили")
                          """,
                    withDuration: 2
                )
            }
            presentIfPossible()
            model.perform(update: .gameStageChange(stage: .mafia))
        default:
            break
        }
    }
    
    private func presentIfPossible() {
        assert(Thread.isMainThread)
        if !coverVC.isPresented {
            present(coverVC, animated: false)
        }
        else {
            coverVC.hidePresentingLabel()
        }
    }
    
    // MARK: Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playersCollectionView.delegate = self
        playersCollectionView.dataSource = self
        playersCollectionView.register(PlayerCollectionViewCell.self, forCellWithReuseIdentifier: "PlayerCell")
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(playersCollectionView)
        playersCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? model.current.aliveUsers.count : model.current.deadUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCell", for: indexPath) as! PlayerCollectionViewCell
        if indexPath.section == 0 {
            cell.setup(
                user: model.current.aliveUsers[indexPath.row],
                image: UIImage(named: "icon\(indexPath.row)")!,
                isDead: false
            )
        } else {
            cell.setup(
                user: model.current.deadUsers[indexPath.row],
                image: UIImage(named: "icon\(indexPath.row + model.current.aliveUsers.count)")!,
                isDead: true
            )
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard indexPath.section == 0 else { return }
        let victimId = model.current.aliveUsers[indexPath.row].id
        guard victimId != model.user.id || model.current.stage == .doctor else {
            presentAlert(title: "Запрещено", message: "Нельзя использовать способность на себя")
            return
        }
        model.makeAction(victimId: victimId)
        if model.current.stage == .townAwaken {
            coverVC.enqueue { [weak coverVC] in
                coverVC?.setTitle(
                    title: "Ожидание хода других игроков",
                    message: "Отдохните",
                    withDuration: 400
                )
            }
            presentIfPossible()
        }
        collectionView.isUserInteractionEnabled = false
    }
}
