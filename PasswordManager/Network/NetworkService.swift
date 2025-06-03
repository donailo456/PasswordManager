//
//  NetworkService.swift
//  PasswordManager
//
//  Created by Komarov Danil on 14.03.2025.
//

import Foundation
import UIKit

final class NetworkService {
    
    //MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    
    //freepik FPSX71afda252fcc459395513b617686e747
    
    //MARK: - Functions
    
    func addFileToIPFS(fileData: Data, completion: ((String?) -> Void)?) {
        let url = URL(string: "http://192.168.0.95:5001/api/v0/add")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"file.txt\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: text/plain\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion?(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let hash = json["Hash"] as? String {
                completion?(hash)
            } else {
                completion?(nil)
            }
        }
        
        task.resume()
    }
    
    func getFileFromIPFS(hash: String, completion: @escaping (Data?) -> Void) {
        let url = URL(string: "http://192.168.0.95:5001/api/v0/cat?arg=\(hash)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            completion(data)
        }
        
        task.resume()
    }

    // Функция для получения всех данных с IPFS
    func getAllDataFromIPFS(completion: @escaping ([String: PasswordEntry]?) -> Void) {
        getPinnedObjects { pinnedObjects in
            guard let pinnedObjects = pinnedObjects else {
                completion(nil)
                return
            }
            
            var allData: [String: PasswordEntry] = [:]
            let group = DispatchGroup()
            
            for cid in pinnedObjects {
                group.enter()
                self.downloadFromIPFS(cid: cid) { data in
                    if let data = data {
                        allData[cid] = data
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(allData)
            }
        }
    }

    func getPinnedObjects(completion: @escaping ([String]?) -> Void) {
        let url = URL(string: "http://192.168.0.95:5001/api/v0/pin/ls")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("Данные не получены")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let keys = json["Keys"] as? [String: Any] {
                    let pinnedObjects = Array(keys.keys)
                    completion(pinnedObjects)
                } else {
                    completion(nil)
                }
            } catch {
                print("Ошибка при парсинге JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func downloadFromIPFS(cid: String, completion: @escaping (PasswordEntry?) -> Void) {
        let url = URL(string: "http://192.168.0.95:5001/api/v0/cat?arg=\(cid)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("Данные не получены")
                completion(nil)
                return
            }
            do {
                let jsonDecod = try self.decoder.decode(PasswordEntry.self, from: data)
                completion(jsonDecod)
            } catch {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func generateImage(from phrase: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // URL эндпоинта
        guard let url = URL(string: "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }
        
        // Параметры запроса
        let parameters: [String: Any] = [
            "text_prompts": [
                ["text": phrase]
            ],
            "cfg_scale": 7,
            "height": 1024,
            "width": 1024,
            "samples": 1,
            "steps": 30
        ]
        
        // Создаем запрос
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer sk-kDslabXU0FjV1HVj1xYX2FzsrwJ81NtW3ryGEq9lfChWsTVw", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Сериализуем параметры в JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        // Выполняем запрос
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Данные не получены"])))
                return
            }
            
            // Парсим JSON-ответ
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let artifacts = json["artifacts"] as? [[String: Any]],
                   let base64Image = artifacts.first?["base64"] as? String,
                   let imgData = Data(base64Encoded: base64Image),
                   let image = UIImage(data: imgData) {
                    completion(.success(image))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось извлечь изображение"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func generateImage1(phrase: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let apiKey = "FPSX71afda252fcc459395513b617686e747"
        let apiUrl = "https://api.freepik.com/v1/ai/text-to-image"

        guard let url = URL(string: apiUrl) else { return }

        let parameters: [String: Any] = [
            "prompt": phrase,
            "negative_prompt": "b&w, cartoon, ugly",
            "guidance_scale": 2,
            "seed": 42,
            "num_images": 1,
            "image": ["size": "square_1_1"],
            "styling": [
                "style": "photo",
                "color": "pastel",
                "lightning": "warm",
                "framing": "portrait"
            ],
            "filter_nsfw": true
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-freepik-api-key")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
//                completion(.failure(.))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(FreepikImageResponse.self, from: data)
                if let base64String = response.data.first?.base64 {
                    if let imageData = Data(base64Encoded: base64String),
                       let image = UIImage(data: imageData) {
                        completion(.success(image))
                    }
                    
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchImage(from phrase: String, completion: @escaping (Data?) -> Void) {
        let url = URL(string: "https://api.stablediffusion.example/generate?phrase=\(phrase.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                completion(data)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}

// Модель ответа
struct FreepikImageResponse: Codable {
    let data: [ImageData]
    
    struct ImageData: Codable {
        let base64: String
        let hasNsfw: Bool
        
        enum CodingKeys: String, CodingKey {
            case base64
            case hasNsfw = "has_nsfw"
        }
    }
}
