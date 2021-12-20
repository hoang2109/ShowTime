//
//  PopularCollection.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation

public struct PopularCollection: Equatable {
    public let items: [Movie]
    public let page: Int
    public let totalPages: Int
    
    public init(items: [Movie], page: Int, totalPages: Int) {
        self.items = items
        self.page = page
        self.totalPages = totalPages
    }
}
