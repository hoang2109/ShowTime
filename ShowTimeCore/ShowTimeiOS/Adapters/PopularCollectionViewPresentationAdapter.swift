//
//  PopularCollectionViewPresentationAdapter.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import ShowTimeCore

final class PopularCollectionViewPresentationAdapter {
    
    var presenter: PopularCollectionViewPresenter?
    
    private let loader: PopularMoviesLoader
    
    init(loader: PopularMoviesLoader) {
        self.loader = loader
    }
}

extension PopularCollectionViewPresentationAdapter: PopularCollectionViewControllerDelegate {
    func didRequestPopularCollection() {
        presenter?.didStartLoadingPopularMovies()
        let request = PopularMoviesRequest(page: 1)
        loader.load(request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(collection):
                self.presenter?.didFinishLoadingPopularMovies(with: collection.items)
            case let .failure(error):
                self.presenter?.didFinishLoadingPopularMovies(with: error)
            }
        }
    }
}
