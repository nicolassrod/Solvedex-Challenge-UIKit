//
//  URLs.swift
//  Solvedex Challenge UIKit
//
//  Created by Nicolás A. Rodríguez on 15/02/24.
//

import Foundation

#if DEBUG
let serverURL = URL.developmentServer
#else
let serverURL = URL.productionServer
#endif

extension URL {
    static let productionServer  = URL(string: "https://dog.ceo/api")!
    static let developmentServer = URL(string: "https://dog.ceo/api")!
    
    // Pug
    static func randomPug(limit: Int) -> URL {
        serverURL.appending(path: "/breed/pug/images/random").appending(component: "\(limit)")
    }
    
    // Exmple Profile
    // ..
    
    // Some Other endpoints
    // ..
}
