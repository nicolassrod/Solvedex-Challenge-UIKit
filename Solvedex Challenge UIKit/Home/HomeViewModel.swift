//
//  HomeViewModel.swift
//  Solvedex Challenge UIKit
//
//  Created by Nicolás A. Rodríguez on 15/02/24.
//

import Foundation
import Combine
import UIKit

class HomeViewModel {
    static let shared = HomeViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var loadedPage = 1
    let dogData = CurrentValueSubject<[Dog], Never>([])
    
    private init() {
        Task {
            await self.fetchImageMetaData(page: 1)
        }
    }
    
    func fetchImageMetaData(page: Int) async {
        do {
            let dogs = try await DogService().getDogs(limit: 5)
                .map { Dog(id: UUID(), image: $0.absoluteURL, likes: 0) }
            
            if page == 1 {
                self.dogData.send(dogs)
            } else {
                let oldValue = self.dogData.value
                let newValue = oldValue + dogs
                self.dogData.send(newValue)
            }
        } catch {
            print(error)
        }
    }
    
    func updateLike(for dog: Dog) {
        let oldValue = self.dogData.value
        var newValue = oldValue
        if let dogIndex = newValue.firstIndex(where: { $0.id == dog.id }) {
            newValue[dogIndex].likes += 1
        }
        
        self.dogData.send(newValue)
    }
    
    func preCaching(source: Dog) {
        ImageFetchingManager.cacheImage(url: source.image)
    }
}
