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
    
    public init(id: Int, title: String, imagePath: String?) {
        self.id = id
        self.title = title
        self.imagePath = imagePath
    }
}
