//
//  CollectionViewAdapterDelegate.swift
//  PasswordManager
//
//  Created by Komarov Danil on 20.04.2025.
//

import Foundation

protocol CollectionViewAdapterDelegate: AnyObject {
    func didSelect(model: MainCellViewModel)
}
