//
//  AddingPasswordViewModel.swift
//  PasswordManager
//
//  Created by Komarov Danil on 09.03.2025.
//

import Foundation
import CryptoKit

final class AddingPasswordViewModel {
    
    //MARK: - Properties
    
    var coordinator: CoordinatorProtocol?
    
    //MARK: - Private properties
    
    private let networkService: NetworkService
    private let bundleID = Bundle.main.bundleIdentifier ?? ""
    private let key = SymmetricKey(size: .bits256)
    
    //MARK: - Init
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    //MARK: - Functions
    
    func requestInfo(user: String, password: String) {
        let infoString = user + "/" + password
        guard let infoData = infoString.data(using: .utf8) else { return }
        guard let key = loadKeyFromKeychain(identifier: bundleID) ?? generateAndSaveKey(identifier: bundleID) else { return }
        do {
            let cryptoData = try encryptAESTEST(data: infoData, key: key)
            networkService.addFileToIPFS(fileData: cryptoData) { hash in
                if let hash = hash {
                    print("File uploaded to IPFS with hash: \(hash)")
                } else {
                    print("Failed to upload file to IPFS")
                }
            }
        } catch {
            print(#function, "error")
        }
    }
}

private extension AddingPasswordViewModel {
    
    //MARK: - Private functions
    
    func encryptAESTEST(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }
    
    func decryptAESTEST(combinedData: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    func saveKeyToKeychain(key: Data, identifier: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: key
        ]
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
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
    
    func generateAndSaveKey(identifier: String) -> SymmetricKey? {
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: keyData
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess ? key : nil
    }
}
