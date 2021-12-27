//
//  MovieDetailMapper.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 26/12/21.
//

import Foundation

final class MovieDetailMapper {
    private init() {}
    
    private let validHTTPCode = 200
    
    static func map(data: Data, response: HTTPURLResponse) -> MovieDetailLoader.Result {
        guard response.statusCode == 200 else {
            return .failure(RemoteMovieDetailLoader.Error.invalidData)
        }
        do {
            let decoder = JSONDecoder()
            let item = try decoder.decode(RemoteMovie.self, from: data)
            return .success(item.toModel)
        } catch {
            return .failure(RemoteMovieDetailLoader.Error.invalidData)
        }
    }
}
