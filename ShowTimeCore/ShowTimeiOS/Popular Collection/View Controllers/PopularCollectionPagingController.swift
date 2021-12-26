//
//  PopularCollectionPagingController.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 25/12/21.
//

import Foundation

protocol PopularCollectionPagingControllerDelegate {
    func didRequestPopularCollection(at page: Int)
}

class PopularCollectionPagingController {
    private var delegate: PopularCollectionPagingControllerDelegate
    private var viewModel: PopularCollectionPagingViewModel?
    
    init(delegate: PopularCollectionPagingControllerDelegate) {
        self.delegate = delegate
    }
    
    func refresh() {
        self.viewModel = nil
        delegate.didRequestPopularCollection(at: 1)
    }
}

extension PopularCollectionPagingController: PopularCollectionPagingViewProtocol {
    func display(_ viewModel: PopularCollectionPagingViewModel) {
        self.viewModel = viewModel
    }
}
