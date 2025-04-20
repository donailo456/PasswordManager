//
//  MainViewModel.swift
//  PasswordManager
//
//  Created by Komarov Danil on 12.01.2025.
//

import Foundation

import CryptoKit

final class MainViewModel {
    
    //MARK: - Properties
    
    var coordinator: CoordinatorProtocol?
    
    //MARK: - Private properties
    
    private let bundleID = Bundle.main.bundleIdentifier ?? ""
    private let networkService: NetworkService
    
    //MARK: - Init
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    //MARK: - Functions
    
    func showAddingPasswordVC() {
        coordinator?.showAddingPasswordVC()
    }
    
    func showDetailVC(model: MainCellViewModel) {
        coordinator?.showDetailVC(model: model)
    }
    
    func getData() -> [MainCellViewModel] {
        var arrayData: [MainCellViewModel] = []
        networkService.getAllDataFromIPFS { [weak self] info in
            guard let self = self, let info = info else { return }
            for (_, data) in info {
                arrayData.append(MainCellViewModel(passwordEntry: data))
//                guard let key = loadKeyFromKeychain(identifier: bundleID) else { fatalError("NOT KEY") }
//                do {
//                    guard let login = Data(base64Encoded: data.encryptedLogin),
//                          let password = Data(base64Encoded: data.encryptedPassword) else { return }
//                    
//                    let loginDecrypt = try decryptAESTEST(combinedData: login, key: key)
//                    let passwordDecrypt = try decryptAESTEST(combinedData: password, key: key)
//                    print("File get to IPFS with hash:", String(data: loginDecrypt, encoding: .utf8))
//                } catch {
//                    fatalError("Не получилось дешифровать")
//                }
            }
        }
        
        //TODO: - убрать
        
        if arrayData.isEmpty {
            return [MainCellViewModel(passwordEntry: PasswordEntry(title: "123", encryptedLogin: "456", encryptedPassword: "789"))]
        }
        
        return arrayData
    }
}

private extension MainViewModel {
    
    //MARK: - Private Functions
    
    func decryptAESTEST(combinedData: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    func loadKeyFromKeychain(identifier: String) -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess {
            if let keyData = item as? Data {
                // Преобразуем Data в SymmetricKey
                return SymmetricKey(data: keyData)
            }
        }
        return nil
    }
}
