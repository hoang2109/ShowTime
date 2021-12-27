//
//  APIEndpoint.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation

public enum APIEndpoint {
    case popularMovies(page: Int, language: String)
    case movieDetail(id: Int)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .popularMovies(page, language):
            let requestURL = baseURL
                .appendingPathComponent("3")
                .appendingPathComponent("movie")
                .appendingPathComponent("popular")
            var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [
                URLQueryItem(name: "language", value: language),
                URLQueryItem(name: "page", value: "\(page)")
            ]
            return urlComponents?.url ?? requestURL
        case let .movieDetail(id):
            return baseURL
              .appendingPathComponent("3")
              .appendingPathComponent("movie")
              .appendingPathComponent("\(id)")
        }
    }
}
