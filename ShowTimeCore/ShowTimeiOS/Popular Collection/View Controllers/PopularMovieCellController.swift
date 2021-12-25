//
//  PopularMovieCellController.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import UIKit
import ShowTimeCore

protocol PopularMovieCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class PopularMovieCellController: PopularMovieViewProtocol {
    
    private let delegate: PopularMovieCellControllerDelegate
    private var cell: PopularMovieCell?

    init(delegate: PopularMovieCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularMovieCell", for: indexPath) as? PopularMovieCell
        delegate.didRequestImage()
        return cell!
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }

    func display(_ viewModel: PopularMovieViewModel<UIImage>) {        
        cell?.imageContainer.isShimmering = viewModel.isLoading
        cell?.movieImageView.image = viewModel.image
        cell?.retryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
