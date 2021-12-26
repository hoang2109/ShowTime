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
        guard let cell = movieView(at: index) as? PopularMovieCell else { return nil }
        
        let indexPath = IndexPath(row: index, section: 0)
        let dl = collectionView.delegate
        dl?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
        return cell
    }
    
    func simulateMovieViewNotVisible(at index: Int) {
        guard let view = simulateMovieViewVisible(at: index) else { return }
        let dl = collectionView.delegate
        let indexPath = IndexPath(row: index, section: 0)
        dl?.collectionView?(collectionView, didEndDisplaying: view, forItemAt: indexPath)
    }
    
    func simulateScrollToBottom() {
        let scrollView = DraggingScrollView()
        scrollView.contentOffset.y = 1000
        scrollViewDidScroll(scrollView)
    }
}

private class DraggingScrollView: UIScrollView {
    override var isDragging: Bool {
        true
    }
}
