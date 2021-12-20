//
//  PopularMoviesLoader.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation

public struct PopularMoviesRequest {
    public let page: Int
    public let language: String

    public init(page: Int, language: String = "en-US") {
      self.page = page
      self.language = language
    }
}

public protocol PopularMoviesLoader {
    typealias Result = Swift.Result<PopularCollection, Error>
    
    func load(_ request: PopularMoviesRequest, completion: (Result) -> Void)
}

