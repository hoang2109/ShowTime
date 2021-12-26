//
//  PopularCollectionViewController.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import ShowTimeCore
import UIKit

public class PopularCollectionViewController: UICollectionViewController, PopularCollectionLoadingViewProtocol {
    
    private var pagingController: PopularCollectionPagingController?
    
    var items = [PopularMovieCellController]() {
        didSet { collectionView.reloadData() }
    }
    
    private var cellControllers = [IndexPath: PopularMovieCellController]()
    
    convenience init(pagingController: PopularCollectionPagingController) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.pagingController = pagingController
    }
    
    public override func viewDidLoad() {
        configureUI()
        refresh()
    }
    
    private func configureUI() {
        collectionView.collectionViewLayout = createLayout(size: view.bounds.size)
        collectionView.dataSource = self
        collectionView.delegate = self
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        collectionView.refreshControl = refreshControl
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PopularMovieCell.self, forCellWithReuseIdentifier: "PopularMovieCell")
    }
    
    private func createLayout(isLandscape: Bool = false, size: CGSize) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnv) -> NSCollectionLayoutSection? in

            let leadingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            let leadingItem = NSCollectionLayoutItem(layoutSize: leadingItemSize)
            leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            let trailingItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
            let trailingItem = NSCollectionLayoutItem(layoutSize: trailingItemSize)
            trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

            let trailingLeftGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0)),
                subitem: trailingItem, count: 2
            )
            
            let trailingRightGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0)),
                subitem: trailingItem, count: 2
            )
            
            let fractionalHeight = isLandscape ? NSCollectionLayoutDimension.fractionalHeight(0.8) : NSCollectionLayoutDimension.fractionalHeight(0.4)
            let groupDimensionHeight: NSCollectionLayoutDimension = fractionalHeight
            
            let rightGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupDimensionHeight),
                subitems: [leadingItem, trailingLeftGroup, trailingRightGroup]
            )
            
            let leftGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupDimensionHeight),
                subitems: [trailingRightGroup, trailingLeftGroup, leadingItem]
            )
            
            let height = isLandscape ? size.height / 0.9 : size.height / 1.25
            let megaGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(height)),
                subitems: [rightGroup, leftGroup]
            )
            
            return NSCollectionLayoutSection(group: megaGroup)
      }
    }
    
    @IBAction private func refresh() {
        pagingController?.refresh()
    }
    
    func display(_ viewModel: PopularCollectionLoadingViewModel) {
        if viewModel.isLoading {
            collectionView.refreshControl?.beginRefreshing()
        } else {
            collectionView.refreshControl?.endRefreshing()
        }
    }
    
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellController(forItemAt: indexPath).view(in: collectionView, forItemAt: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellController(forItemAt: indexPath).preload()
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelCellControllerLoad(forItemAt: indexPath)
    }
    
    private func cellController(forItemAt indexPath: IndexPath) -> PopularMovieCellController {
        return items[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forItemAt indexPath: IndexPath) {
        cellController(forItemAt: indexPath).cancelLoad()
    }
}
