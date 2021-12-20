//
//  PopularMoviesRequest+TestHelpers.swift
//  ShowTimeCoreTests
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation
import ShowTimeCore

extension PopularMoviesRequest {
    func url(baseURL: URL) -> URL {
        return APIEndpoint.popularMovies(page: page, language: language).url(baseURL: baseURL)
    }
}
