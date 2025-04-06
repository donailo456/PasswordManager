//
//  MainCollectionViewCell.swift
//  PasswordManager
//
//  Created by Komarov Danil on 05.02.2025.
//

import UIKit

final class MainCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static let identifire = "MainCollectionViewCell"
    
    //MARK: - Private properties
    
    private var viewModel: MainCellViewModel?
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Имя пользователя"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green
        configure()
        configureLayout()
    }
        
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    
    func configureViewModel(viewModel: MainCellViewModel?) {
        self.viewModel = viewModel
        
        titleLabel.text = viewModel?.passwordEntry.title
    }
}

private extension MainCollectionViewCell {
    
    //MARK: - Private functions
    
    func configure() {
        addSubview(titleLabel)
    }
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
        ])
    }
    
}
