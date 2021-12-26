//
//  PopularMovieImageDataLoaderPresentationAdapter.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import ShowTimeCore

final class PopularMovieImageDataLoaderPresentationAdapter<View: PopularMovieViewProtocol, Image>: PopularMovieCellControllerDelegate where View.Image == Image {
    
    var presenter: PopularMoviePresenter<View, Image>?
    
    private let model: Movie
    private let imageLoader: ImageDataLoader
    private let baseImageURL: URL
    
    private var task: ImageDataLoaderTask?
    
    init(model: Movie, imageLoader: ImageDataLoader, baseImageURL: URL) {
        self.baseImageURL = baseImageURL
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        guard let imagePath = model.imagePath else { return }
        
        presenter?.didStartLoadingImageData(for: model)
        
        task = imageLoader.load(from: makeImageURL(withPath: imagePath), completion: { [weak self, model] result in
            guard let self = self else { return }
            switch result {
            case let .success(imageData):
                self.presenter?.didFinishLoadingImageData(with: imageData, for: model)
            case let .failure(error):
                self.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        })
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
    
    private func makeImageURL(withPath path: String) -> URL {
        return baseImageURL.appendingPathComponent(path)
    }
}

