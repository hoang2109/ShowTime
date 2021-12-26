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
    
    func loadNextPage() {
        if let viewModel = viewModel, let nextPage = viewModel.nextPage {
            delegate.didRequestPopularCollection(at: nextPage)
        }
    }
}

extension PopularCollectionPagingController: PopularCollectionPagingViewProtocol {
    func display(_ viewModel: PopularCollectionPagingViewModel) {
        self.viewModel = viewModel
    }
}
