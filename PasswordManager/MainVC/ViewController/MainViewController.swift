//
//  ViewController.swift
//  PasswordManager
//
//  Created by Komarov Danil on 30.12.2024.
//

import UIKit

final class MainViewController: UIViewController {
    
    var viewModel: MainViewModel?

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
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .black
        return button
    }()
    
    private lazy var adapter = CollectionViewAdapter(collectionView: mainCollectionView)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
        configureAddButton()
        bindCollectionView()
    }
    
    func bindCollectionView() {
        guard let data = viewModel?.getDataMock() else { return }
        adapter.applySnapshot(data: data)
    }
}

private extension MainViewController {
    
    func configure() {
        view.addSubview(mainCollectionView)
        
        configureLayout()
    }
    
    func configureAddButton() {
        addButton = UIBarButtonItem(image: UIImage(named: "ico_add_button"),
                                    style: .plain,
                                    target: self, action: #selector(addAction))
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
    }
    
    @objc
    func addAction() {
        viewModel?.showAddingPasswordVC()
    }
}

