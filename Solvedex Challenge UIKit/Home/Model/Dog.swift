//
//  Dog.swift
//  Solvedex Challenge UIKit
//
//  Created by Nicolás A. Rodríguez on 15/02/24.
//

import Foundation

struct Dog: Identifiable, Hashable {
    let id: UUID
    let image: URL
    var likes: Int
}

extension Dog: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
