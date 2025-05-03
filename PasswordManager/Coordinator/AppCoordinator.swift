//
//  AppCoordinator.swift
//  PasswordManager
//
//  Created by Komarov Danil on 12.01.2025.
//

import UIKit

final class AppCoordinator: CoordinatorProtocol {
    
    //MARK: - Properties
    
    var parentCoordinator: CoordinatorProtocol?
    var children: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    //MARK: - Functions
    
    func showMainVC() {
        let mainVC = MainViewController()
        let networkService = NetworkService()
        let mainViewModel = MainViewModel(networkService: networkService)
        
        mainViewModel.coordinator = self
        mainVC.viewModel = mainViewModel

        navigationController.pushViewController(mainVC, animated: true)
    }
    
    func showAddingPasswordVC() {
        let vc = AddingPasswordViewController()
        let networkService = NetworkService()
        let vm = AddingPasswordViewModel(networkService: networkService)
        
        vm.coordinator = self
        vc.viewModel = vm
        vc.title = "Добавить пароль"
        
        let navController = UINavigationController(rootViewController: vc)
        navigationController.present(navController, animated: true)
    }
    
    func showDetailVC(model: MainCellViewModel, indexPath: Int) {
        let vc = AddingPasswordViewController()
        let networkService = NetworkService()
        let vm = AddingPasswordViewModel(networkService: networkService, model: model, indexPath: indexPath)
        
        vm.coordinator = self
        vc.viewModel = vm
        vc.title = "Изменить пароль"
        
        let navController = UINavigationController(rootViewController: vc)
        navigationController.present(navController, animated: true)
    }
}
