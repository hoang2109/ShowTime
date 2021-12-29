//
//  MovieDetailsComposer.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 29/12/21.
//

import Foundation
import ShowTimeCore
import UIKit

public class MovieDetailsUIComposer {
    private init() { }
    
    public static func compose(movieID: Int, movieDetailsLoader: MovieDetailLoader, imageDataLoader: ImageDataLoader, imageBaseURL: URL) -> MovieDetailsViewController {
        let movieDetailsViewPresentationAdapter = MovieDetailsViewPresentationAdapter<WeakRefVirtualProxy<MovieDetailsViewController>, UIImage>(
            movieId: movieID,
            movieDetailsLoader: MainQueueDispatchDecorator(decoratee: movieDetailsLoader),
            imageDataLoader: MainQueueDispatchDecorator(decoratee: imageDataLoader)) { backdropPath in
            imageBaseURL.appendingPathComponent(backdropPath)
        }
        let viewController = MovieDetailsViewController(delegate: movieDetailsViewPresentationAdapter)
        let presenter = MovieDetailsPresenter(view: WeakRefVirtualProxy(viewController), imageTransformer: UIImage.init)
        movieDetailsViewPresentationAdapter.presenter = presenter
        return viewController
    }
}
