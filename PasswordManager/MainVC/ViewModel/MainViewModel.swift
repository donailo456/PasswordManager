//
//  MainViewModel.swift
//  PasswordManager
//
//  Created by Komarov Danil on 12.01.2025.
//

import Foundation
import CryptoKit

final class MainViewModel {
    var coordinator: CoordinatorProtocol?
    
    func getDataMock() -> [MainCellViewModel] {
        return [MainCellViewModel(title: "1"), MainCellViewModel(title: "2"), MainCellViewModel(title: "3")]
    }
    
    func showAddingPasswordVC() {
        coordinator?.showAddingPasswordVC()
    }
    
    func getData() {
        let message = "Danil / Komarov".data(using: .utf8)!
        
        let key = "mySuperSecretKey1234567890123456".data(using: .utf8)!
        
        do {
            let symmetricKey = try createSymmetricKey(from: key)
            let test1 = try encryptAESTEST(data: message, key: symmetricKey)
            let test2 = try decryptAESTEST(combinedData: test1, key: symmetricKey)
            
            print("PRINT", test1, String(data: test2, encoding: .utf8))
        } catch {
            print("Error")
        }
    }
    
    func encryptAESTEST(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    func decryptAESTEST(combinedData: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    func createSymmetricKey(from data: Data) throws -> SymmetricKey {
        // Проверяем, что размер данных соответствует размеру ключа
        let keySize = SymmetricKeySize.bits256
        if data.count != keySize.bitCount / 8 {
            throw NSError(domain: "Invalid key size", code: -1, userInfo: nil)
        }
        
        // Создаем SymmetricKey из Data
        return SymmetricKey(data: data)
    }
}
