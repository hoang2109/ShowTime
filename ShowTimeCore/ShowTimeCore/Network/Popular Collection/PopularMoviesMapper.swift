//
//  PopularMoviesMapper.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation

final class PopularMoviesMapper {
    private init() {}
    
    private let validHTTPCode = 200
    
    static func map(data: Data, response: HTTPURLResponse) -> PopularMoviesLoader.Result {
        guard response.statusCode == 200 else {
            return .failure(RemotePopularMoviesLoader.Error.invalidData)
        }
        do {
            let decoder = JSONDecoder()
            let item = try decoder.decode(RemotePopularMovies.self, from: data)
            return .success(item.toModel)
        } catch {
            return .failure(RemotePopularMoviesLoader.Error.invalidData)
        }
    }
}
