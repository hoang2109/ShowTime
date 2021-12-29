//
//  WeakRefVirtualProxy.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation
import UIKit

public final class WeakRefVirtualProxy<T: AnyObject> {
    
    private(set) public weak var object: T?
    
    public init(_ object: T) {
        self.object = object
    }
}

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

extension WeakRefVirtualProxy: PopularCollectionPagingViewProtocol where T: PopularCollectionPagingViewProtocol {
    public func display(_ viewModel: PopularCollectionPagingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: MovieDetailsViewProtocol where T: MovieDetailsViewProtocol, T.Image == UIImage {
    func display(_ viewModel: MovieDetailsViewModel<UIImage>) {
        object?.display(viewModel)
    }
}
