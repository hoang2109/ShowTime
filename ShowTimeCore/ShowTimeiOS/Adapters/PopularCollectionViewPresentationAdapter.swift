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
    private var isLoading = false
    
    init(loader: PopularMoviesLoader) {
        self.loader = loader
    }
}

extension PopularCollectionViewPresentationAdapter: PopularCollectionPagingControllerDelegate {
    func didRequestPopularCollection(at page: Int) {
        guard !isLoading else { return }
        isLoading = true
        presenter?.didStartLoadingPopularMovies()
        let request = PopularMoviesRequest(page: page)
        loader.load(request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(collection):
                self.presenter?.didFinishLoadingPopularMovies(with: collection)
            case let .failure(error):
                self.presenter?.didFinishLoadingPopularMovies(with: error)
            }
            self.isLoading = false
        }
    }
}
