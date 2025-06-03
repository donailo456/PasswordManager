//
//  AppDelegate.swift
//  PasswordManager
//
//  Created by Komarov Danil on 30.12.2024.
//

import UIKit
import LocalAuthentication

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator?.showMainVC()
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        if isFirstLaunch() {
            requestFaceIDPermission()
        }
        
        return true
    }
    
    private func requestFaceIDPermission() {
        let context = LAContext()
        var error: NSError?
        
        // Проверяем, доступна ли биометрия
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print("Face ID недоступен: \(error?.localizedDescription ?? "Ошибка")")
            return
        }
        
        let reason = "Разрешите использовать Face ID для входа в приложение"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    // Пользователь разрешил Face ID
                    UserDefaults.standard.set(true, forKey: "isFaceIDEnabled")
                    print("Face ID разрешен!")
                } else {
                    // Пользователь отказался или ошибка
                    UserDefaults.standard.set(false, forKey: "isFaceIDEnabled")
                    print("Отказ или ошибка: \(error?.localizedDescription ?? "Неизвестная ошибка")")
                }
            }
        }
    }

    private func isFirstLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            return true
        }
        return false
    }
}

