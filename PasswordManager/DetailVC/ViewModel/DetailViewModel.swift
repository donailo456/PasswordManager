//
//  DetailViewModel.swift
//  PasswordManager
//
//  Created by Komarov Danil on 06.04.2025.
//

import Foundation

import CryptoKit

class DetailViewModel {
    
    //MARK: - Properties
    
    var coordinator: CoordinatorProtocol?
    
    //MARK: - Private properties
    
    private var model: MainCellViewModel
    
    //MARK: - Init
    
    init(coordinator: CoordinatorProtocol? = nil, model: MainCellViewModel) {
        self.coordinator = coordinator
        self.model = model
    }
}

private extension DetailViewModel {
    
    //MARK: - Private Function
    
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
