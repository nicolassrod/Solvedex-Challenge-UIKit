//
//  DogService.swift
//  Solvedex Challenge UIKit
//
//  Created by Nicolás A. Rodríguez on 15/02/24.
//

import Foundation
import Observation

protocol DogServiceProtocol {
    func getDogs(limit: Int) async throws -> [URL]
}

struct DogService: DogServiceProtocol {
    private let urlSession = URLSession(configuration: .default)
    
    func getDogs(limit: Int) async throws -> [URL] {
        let url = URL.randomPug(limit: limit)
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw DogServiceError.serverError
        }
        
        guard let decoded = try? JSONDecoder().decode(DogResponse.self, from: data) else {
            throw DogServiceError.noData
        }
        
        return decoded.message
    }
}
