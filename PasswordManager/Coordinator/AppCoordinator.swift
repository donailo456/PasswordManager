//
//  AppCoordinator.swift
//  PasswordManager
//
//  Created by Komarov Danil on 12.01.2025.
//

import UIKit

final class AppCoordinator: CoordinatorProtocol {
    
    var parentCoordinator: CoordinatorProtocol?
    var children: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showMainVC() {
        let mainVC = MainViewController()
//        let network = NetworkService()
//        let mainViewModel = MainViewModel.init(networkService: network)
        let mainViewModel = MainViewModel()
        
        mainViewModel.coordinator = self
        mainVC.viewModel = mainViewModel

        navigationController.pushViewController(mainVC, animated: true)
    }
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .black
        return button
    }()
    
    func showAddingPasswordVC() {
        let vc = AddingPasswordViewController()
        let vm = AddingPasswordViewModel()
        
        vm.coordinator = self
        vc.viewModel = vm
        
        let navController = UINavigationController(rootViewController: vc)
        
        navigationController.present(navController, animated: true)
    }
}
