//
//  ImageFetchingManager.swift
//  Solvedex Challenge UIKit
//
//  Created by Nicolás A. Rodríguez on 18/02/24.
//

import Foundation
import UIKit
import Combine

class ImageFetchingManager {
    static func downloadImage(url: URL) -> AnyPublisher<UIImage, Error> {
        let request = URLRequest(url: url)
        
        if let image = CacheManager.shared.getImageFromCache(request: request) {
            return Just<UIImage>(image)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return URLSession.shared.dataTaskPublisher(for: url)
                .timeout(10, scheduler: RunLoop.main, customError: { URLError(.timedOut) })
                .retry(3)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200
                    else {
                        throw URLError(.badServerResponse)
                    }
                    
                    let cache = CachedURLResponse(response: response, data: data)
                    CacheManager.shared.storeAtCache(data: cache, request: request)
                    
                    return data
                }
                .tryMap {
                    guard let image = UIImage(data: $0) else {
                        throw URLError(.cannotDecodeContentData)
                    }
                    
                    return image
                }
                .eraseToAnyPublisher()
        }
    }
    
    static func cacheImage(url: URL)  {
        let request = URLRequest(url: url)
        
        if CacheManager.shared.getImageFromCache(request: request) != nil {
            return
        } else {
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    return
                }
                
                guard let response = response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode
                else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                let cache = CachedURLResponse(response: response, data: data)
                CacheManager.shared.storeAtCache(data: cache, request: request)
            }
            .resume()
        }
    }
}
