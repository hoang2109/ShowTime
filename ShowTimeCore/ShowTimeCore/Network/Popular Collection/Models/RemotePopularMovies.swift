//
//  RemotePopularMovies.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation

struct RemotePopularMovies: Decodable {
    let page: Int
    let total_pages: Int
    let results: [RemoteMovie]
    
    var toModel: PopularCollection {
        return PopularCollection(items: results.map { $0.toModel }, page: page, totalPages: total_pages)
    }
}
