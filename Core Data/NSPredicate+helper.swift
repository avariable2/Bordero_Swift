//
//  NSPredicate+helper.swift
//  Bordero
//
//  Created by Grande Variable on 27/04/2024.
//

import Foundation

extension NSPredicate {
    static let all = NSPredicate(format: "TRUEPREDICATE")
    static let none = NSPredicate(format: "FALSEPREDICATE")
}
