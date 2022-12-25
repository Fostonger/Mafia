import UIKit

class PlayDeskViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let model: GameModel
    
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
    
    init(model: GameModel) {
        self.model = model
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 4)
        
        super.init(collectionViewLayout: layout)
        model.notifier.subscribeWeak(self, type(of: self).handle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func handle(update: GameModel.State.Update) {
        switch update {
        case .usersStateUpdate(_, _, let comissarIsRight):
            collectionView.reloadData()
            coverVC.enqueue { [weak coverVC] in
                coverVC?.setTitle(title: "Комиссар сделал \(comissarIsRight ? "правильный" : "неправильный") выбор")
            }
        case .gameStageChange(let stage):
            stage |> newGameStageHandling
        case .setRole(let role):
            role |> presentRoleSetting
        case .error(let error):
            presentAlert(title: "Ошибка!", message: error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(PlayerCollectionViewCell.self, forCellWithReuseIdentifier: "PlayerCell")
    }
    
    private func presentRoleSetting(role: Role) {
        coverVC.enqueue { [weak coverVC] in
            coverVC?.setTitle(title: "Ваша роль", message: role.localizedName, withDuration: 1)
        }
        if presentedViewController == nil {
            present(coverVC, animated: false)
        }
    }
    
    private func newGameStageHandling(stage: GameStage) {
        let intStage = stage.rawValue
        let intRole = model.current.role?.rawValue ?? 0
        let isAsleep = !(intStage < 1 || intRole == intStage)
        collectionView.isUserInteractionEnabled = !isAsleep
        coverVC.enqueue { [weak coverVC] in
            coverVC?.setTitle(title: stage.localizedStage)
        }
        coverVC.hidePresentingLabel() // Скрываем лейбл прошлого хода
        if isAsleep {
            model.getGameStage()
        } else {
            coverVC.hidePresentingLabel() // Скрываем лейбл нынешнего хода если человеку нужно сходить
        }
    }
    
    // MARK: Collection View
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? model.current.aliveUsers.count : model.current.deadUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCell", for: indexPath) as! PlayerCollectionViewCell
        if indexPath.section == 0 {
            cell.setup(
                user: model.current.aliveUsers[indexPath.row],
                image: UIImage(named: "mafia1")!,
                isDead: false
            )
        } else {
            cell.setup(
                user: model.current.deadUsers[indexPath.row],
                image: UIImage(named: "mafia1")!,
                isDead: true
            )
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard indexPath.section == 0 else { return }
        let victimId = model.current.aliveUsers[indexPath.row].id
        model.makeAction(victimId: victimId)
        collectionView.isUserInteractionEnabled = false
    }
}
