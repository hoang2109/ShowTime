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
    
    public static func compose(loader: PopularMoviesLoader, imageLoader: ImageDataLoader, baseImageURL: URL, onMovieSelection: @escaping (Int) -> ()) -> PopularCollectionViewController {
        let adapter = PopularCollectionViewPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: loader))
        let pagingController = PopularCollectionPagingController(delegate: adapter)
        let viewController = PopularCollectionViewController(pagingController: pagingController)

        adapter.presenter = PopularCollectionViewPresenter(
            popularCollectionView: PopularCollectionViewAdapter(
                controller: viewController,
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader),
                baseImageURL: baseImageURL, onMovieSelection: onMovieSelection),
            loadingView: WeakRefVirtualProxy(viewController),
            pagingView: pagingController
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

// MARK:- MainQueueDispatchDecorator

extension MainQueueDispatchDecorator: PopularMoviesLoader where T == PopularMoviesLoader {
    public func load(_ request: PopularMoviesRequest, completion: @escaping (PopularMoviesLoader.Result) -> Void) {
        decoratee.load(request, completion: { [weak self] result in
            self?.dispatch { completion(result) }
        })
    }
}

extension MainQueueDispatchDecorator: ImageDataLoader where T == ImageDataLoader {
    public func load(from imageURL: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        decoratee.load(from: imageURL, completion: { [weak self] result in
            self?.dispatch { completion(result) }
        })
    }
}

 
