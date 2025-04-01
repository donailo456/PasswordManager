//
//  NetworkService.swift
//  PasswordManager
//
//  Created by Komarov Danil on 14.03.2025.
//

import Foundation

final class NetworkService {
    
    //MARK: - Private Properties
    
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    
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
    
}
