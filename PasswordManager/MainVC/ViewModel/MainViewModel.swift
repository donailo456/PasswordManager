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
    
    func getDataMock() -> [MainCellViewModel] {
        return [MainCellViewModel(title: "1"), MainCellViewModel(title: "2"), MainCellViewModel(title: "3")]
    }
    
    func showAddingPasswordVC() {
        coordinator?.showAddingPasswordVC()
    }
    
    func getData() {
        networkService.getAllDataFromIPFS { [weak self] info in
            guard let self = self, let info = info else { return }
            for (keyDict, data) in info {
                guard let key = loadKeyFromKeychain(identifier: bundleID) else {
                    print("NOT KEY")
                    return
                }
                do {
                    guard let login = Data(base64Encoded: data.encryptedLogin),
                          let password = Data(base64Encoded: data.encryptedPassword) else { return }
                    
                    let loginDecrypt = try decryptAESTEST(combinedData: login, key: key)
                    let passwordDecrypt = try decryptAESTEST(combinedData: password, key: key)
                    print("File get to IPFS with hash:", String(data: loginDecrypt, encoding: .utf8))
                } catch {
                    print("НЕ получилось дешифровать")
                }
            }
        }
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
