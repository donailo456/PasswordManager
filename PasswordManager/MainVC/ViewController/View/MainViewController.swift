//
//  ViewController.swift
//  PasswordManager
//
//  Created by Komarov Danil on 30.12.2024.
//

import UIKit

final class MainViewController: UIViewController {
    
    //MARK: - Properties
    
    var viewModel: MainViewModel?
    
    //MARK: - Private properties

    private lazy var mainCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 20
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collection = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.allowsMultipleSelection = true
        collection.backgroundColor = .clear
        return collection
    }()
    
    private lazy var adapter = CollectionViewAdapter(collectionView: mainCollectionView)
    private lazy var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
        configureAddButton()
        configureCollectionView()
    }
}

private extension MainViewController {
    
    //MARK: - Private functions
    
    func configure() {
        view.addSubview(mainCollectionView)
        adapter.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "Обновление...")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        configureLayout()
    }
    
    func configureAddButton() {
        let addButton = UIBarButtonItem(image: UIImage(named: "ico_add_button"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(addAction))
        addButton.tintColor = .black
        navigationItem.rightBarButtonItem = addButton
    }
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            mainCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        mainCollectionView.refreshControl = refreshControl
    }
    
    func configureCollectionView() {
        guard let data = viewModel?.getData() else { return }
        adapter.applySnapshot(data: data)
    }
    
    @objc
    func addAction() {
        viewModel?.showAddingPasswordVC()
    }
    
    @objc
    func refreshData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let data = viewModel?.getData() else { return }
            adapter.applySnapshot(data: data)
            refreshControl.endRefreshing()
        }
    }
}

extension MainViewController: CollectionViewAdapterDelegate {
    
    //MARK: - CollectionViewAdapterDelegate
    
    func didSelect(model: MainCellViewModel, indexPath: Int) {
        viewModel?.showDetailVC(model: model, indexPath: indexPath)
    }
}

