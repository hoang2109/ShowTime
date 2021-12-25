//
//  PopularCollectionPresenter.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import ShowTimeCore

protocol PopularCollectionLoadingViewProtocol {
    func display(_ viewModel: PopularCollectionLoadingViewModel)
}

protocol PopularCollectionViewProtocol {
    func display(_ viewModel: PopularCollectionViewModel)
}

final class PopularCollectionViewPresenter {

    private let popularCollectionView: PopularCollectionViewProtocol
    private let loadingView: PopularCollectionLoadingViewProtocol
    
    init(popularCollectionView: PopularCollectionViewProtocol, loadingView: PopularCollectionLoadingViewProtocol) {
        self.popularCollectionView = popularCollectionView
        self.loadingView = loadingView
    }
    
    static var title: String {
        return "Popular"
    }

    func didStartLoadingPopularMovies() {
        loadingView.display(PopularCollectionLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingPopularMovies(with movies: [Movie]) {
        popularCollectionView.display(PopularCollectionViewModel(movies: movies))
        loadingView.display(PopularCollectionLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingPopularMovies(with error: Error) {
        loadingView.display(PopularCollectionLoadingViewModel(isLoading: false))
    }
}
