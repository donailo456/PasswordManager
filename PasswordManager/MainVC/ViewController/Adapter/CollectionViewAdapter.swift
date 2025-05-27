//
//  AdapterCollectionView.swift
//  PasswordManager
//
//  Created by Komarov Danil on 05.02.2025.
//

import UIKit

final class CollectionViewAdapter: NSObject {
    
    //MARK: - Typealias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, MainCellViewModel>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, MainCellViewModel>
    
    //MARK: - Properties
    
    var collectionView: UICollectionView
    weak var delegate: CollectionViewAdapterDelegate?
    
    //MARK: - Private properties
    
    private var dataSource: DataSource?
    private var snapShot = DataSourceSnapshot()
    private var cellDataSource: [MainCellViewModel]?
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        
        configure()
    }
    
    //MARK: - Functions
    
    func applySnapshot(data: [MainCellViewModel]) {
        cellDataSource = data
        snapShot.deleteAllItems()
        
        snapShot.appendSections([.main])
        snapShot.appendItems(data)
        
        dataSource?.apply(snapShot, animatingDifferences: true)
        reloadData()
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

private extension CollectionViewAdapter {
    
    //MARK: - Private functions
    
    func configure() {
        collectionView.delegate = self
        registerCell()
        configureCollectionViewDataSource()
    }
    
    func registerCell() {
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.identifire)
    }
    
    func configureCollectionViewDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let viewModel = self.cellDataSource?[indexPath.row] else { return UICollectionViewCell() }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifire, for: indexPath) as? MainCollectionViewCell else { return UICollectionViewCell() }
            cell.configureViewModel(viewModel: viewModel)
            return cell
        })
    }
}

extension CollectionViewAdapter: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = self.cellDataSource?[indexPath.row] else { return }
        delegate?.didSelect(model: viewModel, indexPath: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionViewAdapter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: .zero, bottom: .zero, right: .zero)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width - 32, height: collectionView.bounds.height / 10)
    }
}
