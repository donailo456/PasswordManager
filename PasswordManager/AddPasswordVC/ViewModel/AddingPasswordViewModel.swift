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
        guard let key = loadKeyFromKeychain(identifier: bundleID) ?? generateAndSaveKey(identifier: bundleID) else { return }
        guard let cryptoData = encryptData(title: "123", login: user, password: password, key: key) else { return }
        
        networkService.addFileToIPFS(fileData: cryptoData) { hash in
            if let hash = hash {
                print("File uploaded to IPFS with hash: \(hash)")
            } else {
                print("Failed to upload file to IPFS")
            }
        }
    }
}

private extension AddingPasswordViewModel {
    
    //MARK: - Private functions
    
    func encryptData(title: String, login: String, password: String, key: SymmetricKey) -> Data? {
        guard let loginData = login.data(using: .utf8), let passwordData = password.data(using: .utf8) else { return nil }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let loginBase64 = try encryptAESTEST(data: loginData, key: key).base64EncodedString()
            let passwordBase64 = try encryptAESTEST(data: passwordData, key: key).base64EncodedString()
            let jsonModel = PasswordEntry(title: title, encryptedLogin: loginBase64, encryptedPassword: passwordBase64)

            return try encoder.encode(jsonModel)
//            let jsonDecod = try decoder.decode(PasswordEntry.self, from: jsonData)
//            print("[kd] decode", jsonDecod)
//            guard let dataLogin = Data(base64Encoded: jsonDecod.encryptedLogin) else { return nil }
//            let decrypt = try decryptAESTEST(combinedData: dataLogin, key: key)
//            print("[kd] decrypt", String(data: decrypt, encoding: .utf8))
//            return encryptLogPass
        } catch {
            print(#function, "error")
        }
        
        return nil
    }
    
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
