//
//  MovieDetailsViewControllerTests.swift
//  ShowTimeiOSTests
//
//  Created by Hoang Nguyen on 27/12/21.
//

import Foundation
import XCTest
import ShowTimeiOS
import ShowTimeCore

class MovieDetailsViewControllerTests: XCTestCase {
    
    func test_load_requestsMovieDetailsFromLoader() {
        let (sut, loader) = makeSUT(1)
        
        XCTAssertEqual(loader.movieDetailsLoaderCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.movieDetailsLoaderCount, 1, "Expected a loading request once view is loaded")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ id: Int) -> (sut: MovieDetailsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewController = MovieDetailsViewController(movieID: id, loader: loader)
        return (viewController, loader)
    }
    
    private class LoaderSpy: MovieDetailLoader {
        
        private(set) var movieDetailsLoaderCount = 0
        
        func load(_ id: Int, completion: @escaping (MovieDetailLoader.Result) -> Void) {
            movieDetailsLoaderCount += 1
        }
    }
    
}
