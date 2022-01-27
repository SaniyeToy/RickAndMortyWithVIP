//
//  CharacterListViewController.swift
//  RickAndMortyWithVIP
//
//  Created by MacOS on 27.01.2022.
//

import UIKit
protocol CharactersDisplayLogic: AnyObject {
    func displayCharacters(viewModel: Characters.Fetch.ViewModel)
}

class CharacterListViewController: UIViewController {
    var interactor: CharactersBusinessLogic?
    var router: (CharactersRoutingLogic & CharactersDataPassing)?
    var gridFlowLayout = GridFlowLayout()
    @IBOutlet weak var characterListCollectionView: UICollectionView!
    var viewModel: Characters.Fetch.ViewModel?

    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: Setup

    private func setup() {
        let viewController = self
        let interactor = CharactersInteractor(worker: CharactersWorker())
        let presenter = CharactersPresenter()
        let router = CharactersRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 1
        interactor?.fetchCharacters(request: Characters.Fetch.Request(page: 2))
        characterListCollectionView.register(CharacterListCollectionViewCell.self, forCellWithReuseIdentifier: "CharacterListCollectionViewCell")
        characterListCollectionView.collectionViewLayout = gridFlowLayout
    }
}

extension CharacterListViewController: CharactersDisplayLogic {
    func displayCharacters(viewModel: Characters.Fetch.ViewModel) {
        self.viewModel = viewModel
    }
}
extension CharacterListViewController: UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.characters.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterListCollectionViewCell", for: indexPath) as! CharacterListCollectionViewCell
        guard let model = self.viewModel?.characters[indexPath.item]  else {
            return UICollectionViewCell()
        }
        cell.configure(viewModel: model)
        return cell
    }
}
    
  
