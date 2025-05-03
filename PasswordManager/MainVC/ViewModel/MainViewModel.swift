//
//  MainViewModel.swift
//  PasswordManager
//
//  Created by Komarov Danil on 12.01.2025.
//

import Foundation

import CryptoKit
import KeychainAccess

final class MainViewModel {
    
    //MARK: - Properties
    
    var coordinator: CoordinatorProtocol?
    
    //MARK: - Private properties
    
    private let bundleID = Bundle.main.bundleIdentifier ?? ""
    private let networkService: NetworkService
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "")
    private let recordCountKey = "recordCount"
    
    //MARK: - Init
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    //MARK: - Functions
    
    func showAddingPasswordVC() {
        coordinator?.showAddingPasswordVC()
    }
    
    func showDetailVC(model: MainCellViewModel, indexPath: Int) {
        coordinator?.showDetailVC(model: model, indexPath: indexPath)
    }
    
    func getData() -> [MainCellViewModel] {
        var arrayData: [MainCellViewModel] = []
        if let data = loadData() {
            for element in data {
                arrayData.append(MainCellViewModel(passwordEntry: element))
            }
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
    
    func loadData() -> [PasswordEntry]? {
        guard let recordCount = (try? keychain.get(recordCountKey).flatMap(Int.init)), recordCount != 0 else { return nil }
        var records: [PasswordEntry] = []
        
        for i in 1...recordCount {
            let key = "record_\(i)"
            
            if let jsonString = try? keychain.get(key), let data = jsonString.data(using: .utf8) {
                do {
                    let userData = try JSONDecoder().decode(PasswordEntry.self, from: data)
                    records.append(userData)
                } catch {
                    print("Ошибка декодирования записи \(key): \(error)")
                    return nil
                }
            }
        }

        return records
    }
}
