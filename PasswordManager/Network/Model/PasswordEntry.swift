//
//  PasswordEntry.swift
//  PasswordManager
//
//  Created by Komarov Danil on 30.03.2025.
//

import Foundation

struct PasswordEntry {
    let website: String?
    let encryptedLogin: String
    let encryptedPassword: String
    let encryptedPhrase: String?
    let imageFileName: String?
}

extension PasswordEntry: Codable {}

extension PasswordEntry: Hashable {}
