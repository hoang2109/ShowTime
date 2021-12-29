//
//  MovieDetailsViewPresentationAdapter.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 29/12/21.
//

import Foundation
import ShowTimeCore

class MovieDetailsViewPresentationAdapter<View: MovieDetailsViewProtocol, Image>: MovieDetailsViewControllerDelegate where View.Image == Image {
    
    var presenter: MovieDetailsPresenter<View, Image>?
    
    private let movieId: Int
    private let movieDetailsLoader: MovieDetailLoader
    private let imageDataLoader: ImageDataLoader
    private let makeBackdropImageURL: (String) -> URL
    
    init(movieId: Int, movieDetailsLoader: MovieDetailLoader, imageDataLoader: ImageDataLoader, makeBackdropImageURL: @escaping (String) -> URL) {
        self.movieId = movieId
        self.movieDetailsLoader = movieDetailsLoader
        self.imageDataLoader = imageDataLoader
        self.makeBackdropImageURL = makeBackdropImageURL
    }
    
    func didRequestMovieDetailsData() {
        presenter?.didStartLoading()
        movieDetailsLoader.load(movieId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movie):
                self.presenter?.didFinishLoadingMovieDetailData(with: movie)
                self.loadImageData(for: movie)
            case .failure:
                break
            }
        }
    }
    
    private func loadImageData(for model: Movie) {
        if let backdropMoviePath = model.backdropImagePath {
            imageDataLoader.load(from: makeBackdropImageURL(backdropMoviePath)) { [weak self] result in
                guard let self = self else { return }
                if let data = try? result.get() {
                    self.presenter?.didFinishLoadingImageData(with: data, for: model)
                }
            }
        }
    }
}
