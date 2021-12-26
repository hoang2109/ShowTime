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

public protocol PopularCollectionPagingViewProtocol {
    func display(_ viewModel: PopularCollectionPagingViewModel)
}

final class PopularCollectionViewPresenter {

    private let popularCollectionView: PopularCollectionViewProtocol
    private let loadingView: PopularCollectionLoadingViewProtocol
    private let pagingView: PopularCollectionPagingViewProtocol
    
    init(popularCollectionView: PopularCollectionViewProtocol, loadingView: PopularCollectionLoadingViewProtocol, pagingView: PopularCollectionPagingViewProtocol) {
        self.popularCollectionView = popularCollectionView
        self.loadingView = loadingView
        self.pagingView = pagingView
    }
    
    static var title: String {
        return "Popular"
    }

    func didStartLoadingPopularMovies() {
        loadingView.display(PopularCollectionLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingPopularMovies(with collection: PopularCollection) {
        popularCollectionView.display(PopularCollectionViewModel(page: collection.page, movies: collection.items))
        loadingView.display(PopularCollectionLoadingViewModel(isLoading: false))
        pagingView.display(PopularCollectionPagingViewModel(isLast: collection.page == collection.totalPages, pageNumber: collection.page))
    }

    func didFinishLoadingPopularMovies(with error: Error) {
        loadingView.display(PopularCollectionLoadingViewModel(isLoading: false))
    }
}
