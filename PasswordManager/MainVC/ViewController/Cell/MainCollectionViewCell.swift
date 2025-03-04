//
//  MainCollectionViewCell.swift
//  PasswordManager
//
//  Created by Komarov Danil on 05.02.2025.
//

import UIKit

final class MainCollectionViewCell: UICollectionViewCell {
    
    static let identifire = "MainCollectionViewCell"
    
    private var viewModel: MainCellViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green
    }
        
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(viewModel: MainCellViewModel?) {
        self.viewModel = viewModel
    }
}
