//
//  PopularCollectionViewController+TestHelpers.swift
//  ShowTimeiOSTests
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import ShowTimeiOS
import UIKit

extension PopularCollectionViewController {
    var isShowingLoadingIndicator: Bool {
        return collectionView.refreshControl!.isRefreshing
    }
    
    func simulateUserInitiatedReload() {
        self.collectionView.refreshControl?.simulateRefreshing()
    }
    
    func numberOfRenderedMovieViews() -> Int {
        self.collectionView.numberOfItems(inSection: 0)
    }
    
    func movieView(at index: Int) -> UICollectionViewCell? {
        let ds = collectionView.dataSource
        let indexPath = IndexPath(row: index, section: 0)
        return ds?.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    @discardableResult
    func simulateMovieViewVisible(at index: Int) -> PopularMovieCell? {
        movieView(at: index) as? PopularMovieCell
    }
    
    func simulateMovieViewNotVisible(at index: Int) {
        let view = movieView(at: index)
        let dl = collectionView.delegate
        let indexPath = IndexPath(row: index, section: 0)
        dl?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: indexPath)
    }
}
