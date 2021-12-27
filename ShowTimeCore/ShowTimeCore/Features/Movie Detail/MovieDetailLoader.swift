//
//  MovieDetailLoader.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 26/12/21.
//

import Foundation

public protocol MovieDetailLoader {
    typealias Result = Swift.Result<Movie, Error>
    
    func load(_ id: Int, completion: @escaping (Result) -> Void)
}
