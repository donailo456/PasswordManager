//
//  PasswordEntry.swift
//  PasswordManager
//
//  Created by Komarov Danil on 30.03.2025.
//

import Foundation

struct PasswordEntry {
    let title: String
    let encryptedLogin: String
    let encryptedPassword: String
}

extension PasswordEntry: Codable {}

extension PasswordEntry: Hashable {}
