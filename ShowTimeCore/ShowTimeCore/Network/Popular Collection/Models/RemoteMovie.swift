//
//  RemoteMovie.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation

struct RemoteMovie: Decodable {
    let id: Int
    let poster_path: String?
    let title: String
    
    var toModel: Movie {
        Movie(id: id, title: title, imagePath: poster_path)
    }
}
