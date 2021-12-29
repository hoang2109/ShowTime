//
//  MovieDetailsPresenter.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 29/12/21.
//

import Foundation
import ShowTimeCore

protocol MovieDetailsViewProtocol {
    associatedtype Image
    func display(_ viewModel: MovieDetailsViewModel<Image>)
}

class MovieDetailsPresenter<View: MovieDetailsViewProtocol, Image> where View.Image == Image {
    
    private let view: View
    private let imageTransformer: (Data) -> Image?

    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoading() {
        view.display(.showLoading)
    }
    
    public func didFinishLoadingMovieDetailData(with movie: Movie) {
        view.display(MovieDetailsViewModel<Image>(
            title: movie.title,
            meta: makeMovieMeta(length: movie.length ?? 0, genres: movie.genres),
            overView: movie.overview,
            image: nil,
            isLoading: false)
        )
    }
    
    public func didFinishLoadingImageData(with data: Data, for movie: Movie) {
        view.display(MovieDetailsViewModel<Image>(
            title: movie.title,
            meta: makeMovieMeta(length: movie.length ?? 0, genres: movie.genres),
            overView: movie.overview,
            image: imageTransformer(data),
            isLoading: false)
        )
    }
    
    private func makeMovieMeta(length: Int, genres: [String]) -> String {
        let runTime = Double(length * 60).asString(style: .short)
        let genres = genres.map { $0.capitalizingFirstLetter() }.joined(separator: ", ")
        return "\(runTime) | \(genres)"
    }
}
