//
//  PasswordEntry.swift
//  PasswordManager
//
//  Created by Komarov Danil on 30.03.2025.
//

import Foundation

struct PasswordEntry: Codable {
    let title: String
    let encryptedLogin: String
    let encryptedPassword: String
}
