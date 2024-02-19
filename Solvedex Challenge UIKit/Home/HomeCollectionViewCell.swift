//
//  HomeCollectionViewCell.swift
//  Solvedex Challenge UIKit
//
//  Created by Nicolás A. Rodríguez on 15/02/24.
//

import UIKit
import Combine

class ImageCellViewModel {
    private var subscriptions = Set<AnyCancellable>()
    
    let image = CurrentValueSubject<UIImage, Never>(UIImage())
    let likes = CurrentValueSubject<String, Never>("")
    
    init(source: Dog) {
        ImageFetchingManager.downloadImage(url: source.image)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print(error)
                default:
                    break
                }
            }, receiveValue: { [weak self] value in
                guard let self = self else { return }
                // Update image
                self.image.send(value)
            })
            .store(in: &subscriptions)
        
        self.likes.send("\(source.likes)")
    }
}

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    private var viewModel: ImageCellViewModel?
    private var subscriptions = Set<AnyCancellable>()
    
    private var dog: Dog?
    
    func setUp(viewModel: ImageCellViewModel, dog: Dog) {
        self.viewModel = viewModel
        
        self.dog = dog
        self.likeButton.titleLabel?.text = "\(dog.likes)"
        
        setBinding()
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        guard let dog = dog else { return }
        HomeViewModel.shared.updateLike(for: dog)
    }
    
    func setBinding() {
        guard let viewModel = viewModel else {
            return
        }
        
        viewModel.image
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.image.image = value
            })
            .store(in: &subscriptions)
    }
}
