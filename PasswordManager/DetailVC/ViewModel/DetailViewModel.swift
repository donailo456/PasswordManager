//
//  DetailViewModel.swift
//  PasswordManager
//
//  Created by Komarov Danil on 06.04.2025.
//

import Foundation

class DetailViewModel {
    
    //MARK: - Properties
    
    var coordinator: CoordinatorProtocol?
    
    //MARK: - Init
    
    init(coordinator: CoordinatorProtocol? = nil) {
        self.coordinator = coordinator
    }
}
