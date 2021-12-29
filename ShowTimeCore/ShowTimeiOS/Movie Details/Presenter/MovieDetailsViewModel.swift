//
//  MovieDetailsViewModel.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 29/12/21.
//

import Foundation

struct MovieDetailsViewModel<Image> {
    let title: String?
    let meta: String?
    let overView: String?
    let image: Image?
    let isLoading: Bool
    
    static var showLoading: MovieDetailsViewModel<Image> {
        return MovieDetailsViewModel(title: nil, meta: nil, overView: nil, image: nil, isLoading: true)
    }
}
