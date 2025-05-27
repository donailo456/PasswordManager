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
    
    private lazy var wordsLabel: UILabel = {
        let label = UILabel()
        label.text = "A"
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .darkGray
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nodeLabel: UILabel = {
        let label = UILabel()
        label.text = "Заметка/Сайт:"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configureLayout()
    }
        
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    
    func configureViewModel(viewModel: MainCellViewModel?) {
        self.viewModel = viewModel
    
        if let website = viewModel?.passwordEntry.website {
            nodeLabel.text = website
            wordsLabel.text = String(website.first?.description ?? "")
        }
        emailLabel.text = viewModel?.passwordEntry.encryptedLogin
    }
}

private extension MainCollectionViewCell {
    
    //MARK: - Private functions
    
    func configure() {
        backgroundColor = .lightGray
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 16
        clipsToBounds = true
        
        addSubview(wordsLabel)
        addSubview(nodeLabel)
        addSubview(emailLabel)
    }
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            wordsLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            wordsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            wordsLabel.widthAnchor.constraint(equalToConstant: self.bounds.height - 20),
            wordsLabel.heightAnchor.constraint(equalToConstant: self.bounds.height - 20),
            
            nodeLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8.0),
            nodeLabel.leadingAnchor.constraint(equalTo: wordsLabel.trailingAnchor, constant: 10.0),
            
            emailLabel.topAnchor.constraint(equalTo: nodeLabel.bottomAnchor, constant: 5),
            emailLabel.leadingAnchor.constraint(equalTo: wordsLabel.trailingAnchor, constant: 10.0),
            
        ])
    }
    
}
