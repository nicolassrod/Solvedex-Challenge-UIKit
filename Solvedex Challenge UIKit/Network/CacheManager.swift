//
//  CacheManager.swift
//  Solvedex Challenge UIKit
//
//  Created by Nicolás A. Rodríguez on 18/02/24.
//

import Foundation
import UIKit

class CacheManager {
    static let shared = CacheManager()
    
    // 10MB on memory, 40MB on disk
    let cacheStorage = URLCache(memoryCapacity: 10*1024*1024, diskCapacity: 40*1024*1024, diskPath: nil)
    
    func getImageFromCache(request: URLRequest) -> UIImage? {
        if let cachedData = self.cacheStorage.cachedResponse(for: request) {
            let image = UIImage(data: cachedData.data)
            return image
        } else {
            return nil
        }
    }
    
    func storeAtCache(data: CachedURLResponse, request: URLRequest) {
        self.cacheStorage.storeCachedResponse(data, for: request)
    }
}
