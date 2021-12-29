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
            pagingView: WeakRefVirtualProxy(pagingController)
        )
        viewController.title = PopularCollectionViewPresenter.title
        return viewController
    }
}

 
