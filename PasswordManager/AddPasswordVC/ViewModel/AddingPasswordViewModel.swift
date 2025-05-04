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
        
        do {
            encryptImageData(imageData: imageData, imageFileURL: imageFileURL)
            try keychain.set(key.withUnsafeBytes { Data($0).base64EncodedString() }, key: "encryptionKey_\(imageFileName)")
        } catch {
            print("Ошибка сохранения изображения: \(error)")
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
    
    func encryptImageData(imageData: Data, imageFileURL: URL) {
        do {
            let encryptedData = try ChaChaPoly.seal(imageData, using: key).combined
            try encryptedData.write(to: imageFileURL)
        } catch {
            print("Не полочилось расшифровать сообщение")
        }
    }
    
    func decryptImageData(encryptedData: Data, imageFileName: String) -> UIImage? {
        guard let encryptionKeyString = try? keychain.get("encryptionKey_\(imageFileName)"),
              let encryptionKeyData = Data(base64Encoded: encryptionKeyString),
              let sealedBox = try? ChaChaPoly.SealedBox(combined: encryptedData) else { return nil }
        
        let key = SymmetricKey(data: encryptionKeyData)
        
        do {
            let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
            return UIImage(data: decryptedData)
        } catch {
            print("Не полочилось расшифровать сообщение")
        }
        
        return nil
    }
}
