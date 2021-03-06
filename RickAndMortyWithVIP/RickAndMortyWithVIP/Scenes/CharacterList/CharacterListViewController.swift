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
    var viewModel: Characters.Fetch.ViewModel?
    
    @IBOutlet weak var characterListCollectionView: UICollectionView!
    @IBOutlet weak var characterListSearchBar: UISearchBar!
    
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
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.title = "Characters"
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
        var params: [String: Any] = [String: Any]()
        params["page"] = 1
        interactor?.fetchCharacters(params: params)
        let nib = UINib(nibName: "CharacterListCollectionViewCell", bundle: nil)
        characterListCollectionView.register(nib, forCellWithReuseIdentifier: "CharacterListCollectionViewCell")
        characterListCollectionView.collectionViewLayout = gridFlowLayout
    }
}

extension CharacterListViewController: CharactersDisplayLogic {
    func displayCharacters(viewModel: Characters.Fetch.ViewModel) {
        self.viewModel = viewModel
        characterListCollectionView.reloadData()
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
        cell.addTapGesture { [self] in
            router?.routeToCharacterDetail(index: indexPath.row)
        }
        cell.configure(viewModel: model)
        return cell
    }
}

extension CharacterListViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(CharacterListViewController.reload), object: nil)
        self.perform(#selector(CharacterListViewController.reload), with: nil, afterDelay: 0.7)
    }
    
    @objc func reload() {
        guard let searchText = characterListSearchBar.text else { return }
        
        if searchText == "" {
            self.viewModel?.characters.removeAll()
            var params: [String: Any] = [String: Any]()
            params["page"] = 1
            interactor?.fetchCharacters(params: params)
            characterListCollectionView.reloadData()
        } else {
            search(searchText: searchText)
        }
    }
    
    func search(searchText: String){
        var filteredData : [Characters.Fetch.ViewModel.Character] = []
        for task in (viewModel?.characters)! {
            let str = task.name
            if str!.lowercased().contains(searchText.lowercased()){
                filteredData.append(task)
            }
        }
        viewModel?.characters.removeAll()
        viewModel?.characters.append(contentsOf: filteredData)
        characterListCollectionView.reloadData()
    }
}


