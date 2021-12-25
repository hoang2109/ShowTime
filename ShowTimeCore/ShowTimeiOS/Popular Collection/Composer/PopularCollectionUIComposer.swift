//
//  PopularCollectionUIComposer.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import ShowTimeCore
import UIKit


public class PopularCollectionUIComposer {
    private init() { }
    
    public static func compose(loader: PopularMoviesLoader, imageLoader: ImageDataLoader, baseImageURL: URL) -> PopularCollectionViewController {
        let adapter = PopularCollectionViewPresentationAdapter(loader: loader)
        let viewController = PopularCollectionViewController()
        viewController.delegate = adapter

        adapter.presenter = PopularCollectionViewPresenter(
            popularCollectionView: PopularCollectionViewAdapter(
                controller: viewController,
                imageLoader: imageLoader,
                baseImageURL: baseImageURL),
            loadingView: WeakRefVirtualProxy(viewController)
        )
        viewController.title = PopularCollectionViewPresenter.title
        return viewController
    }
}



// MARK: - WeakRefVirtualProxy

extension WeakRefVirtualProxy: PopularCollectionViewProtocol where T: PopularCollectionViewProtocol {
    func display(_ viewModel: PopularCollectionViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: PopularCollectionLoadingViewProtocol where T: PopularCollectionLoadingViewProtocol {
    func display(_ viewModel: PopularCollectionLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: PopularMovieViewProtocol where T: PopularMovieViewProtocol, T.Image == UIImage {
    
    func display(_ model: PopularMovieViewModel<UIImage>) {
        object?.display(model)
    }
}

 
