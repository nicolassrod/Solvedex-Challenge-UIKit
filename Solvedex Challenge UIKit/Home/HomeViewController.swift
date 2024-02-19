//
//  HomeViewController.swift
//  Solvedex Challenge UIKit
//
//  Created by Nicolás A. Rodríguez on 15/02/24.
//

import UIKit
import Combine

class HomeViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    private var viewModel = HomeViewModel.shared
    private var subscriptions = Set<AnyCancellable>()
    
    enum Section {
      case main
    }
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section , Dog> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, Dog>(
            collectionView: collectionView
        ) { collectionView, indexPath, dataSource -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HomeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.setUp(viewModel: ImageCellViewModel(source: dataSource), dog: dataSource)
            return cell
        }
        
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
        
        setData()
    }
    
    func setData() {
        self.viewModel.dogData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedData in
                guard let self = self else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<Section, Dog>()
                snapshot.appendSections([.main])
                snapshot.appendItems(updatedData, toSection: .main)
                self.dataSource.applySnapshotUsingReloadData(snapshot)
            }
            .store(in: &subscriptions)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        let cellHeight = 300.0
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}


extension HomeViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let row = indexPaths.first?.row else {
            return
        }
        
        let dataSources = self.viewModel.dogData.value
        let source = dataSources[row]
        
        self.viewModel.preCaching(source: source)
        
        if row == dataSources.count - 2 {
            Task { @MainActor in
                let loadedPage = self.viewModel.loadedPage
                await self.viewModel.fetchImageMetaData(page: loadedPage + 1)
                self.viewModel.loadedPage += 1
            }
        }
    }
}
