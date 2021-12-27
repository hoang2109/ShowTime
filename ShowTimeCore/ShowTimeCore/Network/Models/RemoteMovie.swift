//
//  RemoteMovie.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation

struct RemoteMovie: Decodable {
    struct RemoteMovieGenre: Decodable {
        let name: String
    }
    
    let id: Int
    let poster_path: String?
    let title: String
    let overview: String
    let runtime: Int?
    let backdrop_path: String?
    let genres: [RemoteMovieGenre]?
    let vote_average: Float
    
    var toModel: Movie {
        Movie(id: id, title: title, imagePath: poster_path, rating: vote_average, length: runtime, genres: genres?.map { $0.name } ?? [], overview: overview, backdropImagePath: backdrop_path)
    }
}
