//
//  PopularCollectionPagingViewModel.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 25/12/21.
//

import Foundation

public struct PopularCollectionPagingViewModel: Equatable {
    public let isLast: Bool
    public let pageNumber: Int
    
    public var nextPage: Int? {
        isLast ? nil : pageNumber + 1
    }
    
    public init(isLast: Bool, pageNumber: Int) {
        self.isLast = isLast
        self.pageNumber = pageNumber
    }
}
