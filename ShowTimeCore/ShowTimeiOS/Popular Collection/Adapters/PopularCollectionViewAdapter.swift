//
//  PopularCollectionViewAdapter.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import ShowTimeCore
import UIKit

final class PopularCollectionViewAdapter {
    
    private weak var controller: PopularCollectionViewController?
    private let imageLoader: ImageDataLoader
    private let baseImageURL: URL
    private let onMovieSelection: (Int) -> Void
    
    init(controller: PopularCollectionViewController, imageLoader: ImageDataLoader, baseImageURL: URL, onMovieSelection: @escaping (Int) -> Void) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.baseImageURL = baseImageURL
        self.onMovieSelection = onMovieSelection
    }
}

extension PopularCollectionViewAdapter: PopularCollectionViewProtocol {
    func display(_ viewModel: PopularCollectionViewModel) {
        let cellControllers = viewModel.movies.map(makeCellController(for:))
        if (viewModel.page == 1) {
            controller?.set(cellControllers)
        } else {
            controller?.append(cellControllers)
        }
    }
    
    private func makeCellController(for model: Movie) -> PopularMovieCellController {
        let adapter = PopularMovieImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<PopularMovieCellController>, UIImage>(
            model: model,
            imageLoader: imageLoader,
            baseImageURL: baseImageURL
        )
        
        let id = model.id
        let view = PopularMovieCellController(delegate: adapter) { [weak self] in
            guard let self = self else { return }
            self.onMovieSelection(id)
        }
        adapter.presenter = PopularMoviePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
        return view
    }
}
