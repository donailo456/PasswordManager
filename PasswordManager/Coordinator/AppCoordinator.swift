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
    
    func start() {
        showMainVC()
    }
    
    private func showMainVC() {
        let mainVC = MainViewController()
//        let network = NetworkService()
//        let mainViewModel = MainViewModel.init(networkService: network)
        let mainViewModel = MainViewModel()
        
        mainViewModel.coordinator = self
        mainVC.viewModel = mainViewModel
        
        navigationController.pushViewController(mainVC, animated: true)
    }
}
