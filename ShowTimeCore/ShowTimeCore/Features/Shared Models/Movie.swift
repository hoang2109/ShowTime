//
//  PopularMovie.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation

public struct Movie: Equatable {
    
    public let id: Int
    public let title: String
    public let imagePath: String?
    public let rating: Float?
    public let length: Int?
    public let genres: [String]
    public let overview: String
    public let backdropImagePath: String?
    
    public init(id: Int, title: String, imagePath: String? = nil, rating: Float? = nil, length: Int? = nil, genres: [String] = [], overview: String = "", backdropImagePath: String? = nil) {
        self.id = id
        self.title = title
        self.imagePath = imagePath
        self.rating = rating
        self.length = length
        self.genres = genres
        self.overview = overview
        self.backdropImagePath = backdropImagePath
    }
}
