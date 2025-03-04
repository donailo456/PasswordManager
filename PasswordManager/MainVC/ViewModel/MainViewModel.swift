//
//  MainViewModel.swift
//  PasswordManager
//
//  Created by Komarov Danil on 12.01.2025.
//

import Foundation

final class MainViewModel {
    var coordinator: CoordinatorProtocol?
    
    func getDataMock() -> [MainCellViewModel] {
        return [MainCellViewModel(title: "1"), MainCellViewModel(title: "2"), MainCellViewModel(title: "3")]
    }
}
