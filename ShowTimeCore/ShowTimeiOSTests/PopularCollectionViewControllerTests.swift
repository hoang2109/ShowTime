//
//  PopularCollectionViewControllerTests.swift
//  ShowTimeiOSTests
//
//  Created by Hoang Nguyen on 22/12/21.
//

import Foundation
import XCTest
import ShowTimeCore

class PopularCollectionViewController {
    private let popularMoviesLoader: PopularMoviesLoader
    
    init(popularMoviesLoader: PopularMoviesLoader) {
        self.popularMoviesLoader = popularMoviesLoader
    }
}

class PopularCollectionViewControllerTests: XCTestCase {
    
    func test_load_requestsPopularMoviesFromLoader() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.popularMoviesLoaderCount, 0, "Expected no loading requests before view is loaded")
    }
    
    // MARK: - Helper
    
    private func makeSUT() -> (viewController: PopularCollectionViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewController = PopularCollectionViewController(popularMoviesLoader: loader)
        
        return (viewController, loader)
    }
    
    private class LoaderSpy: PopularMoviesLoader {
        
        private(set) var popularMoviesLoaderCount = 0
        
        func load(_ request: PopularMoviesRequest, completion: @escaping (PopularMoviesLoader.Result) -> Void) {
            popularMoviesLoaderCount += 1
        }
    }
}
