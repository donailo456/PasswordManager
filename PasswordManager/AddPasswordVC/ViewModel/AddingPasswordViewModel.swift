//
//  AddingPasswordViewModel.swift
//  PasswordManager
//
//  Created by Komarov Danil on 09.03.2025.
//

import Foundation
import CryptoKit
import UIKit
import KeychainAccess

final class AddingPasswordViewModel {
    
    //MARK: - Properties
    
    var coordinator: CoordinatorProtocol?
    let model: PasswordEntry?
    
    //MARK: - Private properties
    
    private let networkService: NetworkService
    private let indexPath: Int?
    private let bundleID = Bundle.main.bundleIdentifier ?? ""
    private let key = SymmetricKey(size: .bits256)
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "")
    private let recordCountKey = "recordCount"
    
    //MARK: - Init
    
    init(networkService: NetworkService, model: MainCellViewModel? = nil, indexPath: Int? = nil) {
        self.networkService = networkService
        self.model = model?.passwordEntry
        self.indexPath = indexPath
    }
    
    //MARK: - Functions
    
    func requestAIImage(phrase: String, completion: @escaping ((UIImage?) -> Void) ) {
        //        DispatchQueue.main.async { [weak self] in
        //            guard let self = self else { return }
        //            self.networkService.generateImage(from: phrase) { result in
        //                switch result {
        //                case let .success(image):
        //                    completion(image)
        //                case let .failure(error):
        //                    fatalError("ИИ фотка: \(error)")
        //                }
        //            }
        //        }
        
        //            guard let self = self else { return }
        self.networkService.generateImage1(phrase: phrase) { result in
            switch result {
            case let .success(image):
                DispatchQueue.main.async {
                    completion(image)
                }
            case let .failure(error):
                fatalError("ИИ фотка: \(error)")
            }
        }
    }
    
    
    
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
//    
//    func showingData() -> PasswordEntry? {
//        guard let model = model?.passwordEntry else { return nil }
//        
//        return model
//    }
    
    func showImage(imageFileName: String?) -> UIImage? {
        guard let imageFileName = imageFileName else { return nil }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageFileURL = documentsDirectory.appendingPathComponent(imageFileName)
        if let encryptedData = try? Data(contentsOf: imageFileURL),
           let encryptionKeyString = try? keychain.get("encryptionKey_\(imageFileName)"),
           let encryptionKeyData = Data(base64Encoded: encryptionKeyString),
           let sealedBox = try? ChaChaPoly.SealedBox(combined: encryptedData) {
            
            let key = SymmetricKey(data: encryptionKeyData)
            guard let decryptedData = try? ChaChaPoly.open(sealedBox, using: key) else { return nil }
            
            return UIImage(data: decryptedData)
        }
        
        return nil
    }
    
    func algorithСreatingPassword(phrase: String) -> String {
        let splitStr = phrase.split(separator: " ")
        let filteredStr = splitStr.filter { element in
            let isNumber = Int(element) != nil || Double(element) != nil
            return isNumber || element.count >= 2
        }
        var result: [String] = []
        
        filteredStr.forEach { element in
            if Int(element) != nil {
                result.append(String(element))
            } else {
                let str = String(element)
                result.append(String(str.prefix(3)))
            }
        }
        return result.joined()
    }
    
    func saveData(website: String?, login: String, password: String, phrase: String?, image: UIImage?) {
        let imageFileName: String? = image != nil ? "image_\(UUID().uuidString).jpg" : nil
        saveImage(image: image, imagaFile: imageFileName)
        let recordCount = (try? keychain.get(recordCountKey).flatMap(Int.init)) ?? 0
        let newRecordKey = "record_\(recordCount + 1)"
        let userData = PasswordEntry(website: website,
                                     encryptedLogin: login,
                                     encryptedPassword: password,
                                     encryptedPhrase: phrase,
                                     imageFileName: imageFileName)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(userData)
            let jsonString = String(data: data, encoding: .utf8)!
            
            try keychain.set(jsonString, key: newRecordKey)
            try keychain.set(String(recordCount + 1), key: recordCountKey)
        } catch {
            fatalError("ошибка при загрузке данных")
        }
    }
    
    func saveImage(image: UIImage?, imagaFile: String?) {
        
        guard let image = image,
                let imageData = image.jpegData(compressionQuality: 0.8),
                let imageFileName = imagaFile
        else { return }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageFileURL = documentsDirectory.appendingPathComponent(imageFileName)
        
        let encryptionKey = SymmetricKey(size: .bits256)
        if let encryptedData = try? ChaChaPoly.seal(imageData, using: encryptionKey).combined {
            do {
                try encryptedData.write(to: imageFileURL)
                // Сохраняем ключ шифрования в Keychain для доступа к изображению
                try keychain.set(encryptionKey.withUnsafeBytes { Data($0).base64EncodedString() }, key: "encryptionKey_\(imageFileName)")
            } catch {
                print("Ошибка сохранения изображения: \(error)")
            }
        }
    }
    
    func loadData() -> [PasswordEntry]? {
        let recordCount = (try? keychain.get(recordCountKey).flatMap(Int.init)) ?? 0
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
    
    func generateLocalMnemonicPhrase(wordCount: Int = 4) -> String {
        
        // Массивы категорий
        let colors = WordsArray.colors
        let nouns = WordsArray.nouns
        let verbs = WordsArray.verbs
        let adjectives = WordsArray.adjectives
        var selectedWords: [String] = []
        
        if let color = colors.randomElement() {
            selectedWords.append(color)
        }
        
        if wordCount > 1, let noun = nouns.randomElement() {
            selectedWords.append(noun)
        }
        
        if wordCount > 2, let verb = verbs.randomElement() {
            selectedWords.append(verb)
        }
        
        if wordCount > 3, let adjective = adjectives.randomElement() {
            selectedWords.append(adjective)
        }
        
        if wordCount > 4 {
            let remainingWords = (nouns + verbs + adjectives).shuffled()
            let additionalWords = remainingWords.prefix(wordCount - 4)
            selectedWords.append(contentsOf: additionalWords)
        }

        let phrase = selectedWords.joined(separator: " ")
        
        return phrase
    }
    
    func deleteRecord() {
        guard let indexPath = indexPath else { return }
        let index = indexPath + 1
        let recordKey = "record_\(index)"
        do {
            guard (try? keychain.get(recordKey)) != nil else {
                fatalError("Запись с индексом \(index) не найдена")
            }
            
            try keychain.remove(recordKey)
            deleteImage()
            
            let recordCount = (try? keychain.get(recordCountKey).flatMap(Int.init)) ?? 0
            guard index < recordCount else {
                let newRecordCount = recordCount - 1
                try keychain.set(String(newRecordCount), key: recordCountKey)
                return
            }
            
            for i in index...(recordCount - 1) {
                let nextKey = "record_\(i + 1)"
                let newKey = "record_\(i)"
                if let nextRecord = try? keychain.get(nextKey) {
                    try keychain.set(nextRecord, key: newKey)
                }
            }
            
            try keychain.remove("record_\(recordCount)")
            
            let newRecordCount = recordCount - 1
            try keychain.set(String(newRecordCount), key: recordCountKey)
        } catch {
            fatalError("Ошибка при удалении записи: \(error)")
        }
    }
    
    func deleteImage() {
        guard let imageFileName = model?.imageFileName else { return }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageFileURL = documentsDirectory.appendingPathComponent(imageFileName)
        try? FileManager.default.removeItem(at: imageFileURL)
        
        // Удаляем ключ шифрования
        let encryptionKeyKey = "encryptionKey_\(imageFileName)"
        try? keychain.remove(encryptionKeyKey)
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
            let jsonModel = PasswordEntry(website: title, encryptedLogin: loginBase64, encryptedPassword: passwordBase64, encryptedPhrase: nil, imageFileName: nil)

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
