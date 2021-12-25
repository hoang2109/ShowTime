//
//  PopularMoviePresenter.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import ShowTimeCore

struct PopularMovieViewModel<Image> {
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}

protocol PopularMovieViewProtocol {
    associatedtype Image

    func display(_ model: PopularMovieViewModel<Image>)
}

final class PopularMoviePresenter<View: PopularMovieViewProtocol, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    internal init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImageData(for model: Movie) {
        view.display(PopularMovieViewModel(
            image: nil,
            isLoading: true,
            shouldRetry: false)
        )
    }

    private struct InvalidImageDataError: Error {}

    func didFinishLoadingImageData(with data: Data, for model: Movie) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }

        view.display(PopularMovieViewModel(
            image: image,
            isLoading: false,
            shouldRetry: false)
        )
    }

    func didFinishLoadingImageData(with error: Error, for model: Movie) {
        view.display(PopularMovieViewModel(
            image: nil,
            isLoading: false,
            shouldRetry: true)
        )
    }
}
