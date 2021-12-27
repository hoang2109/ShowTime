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
    
    func test_loadingIndicator_isVisibleWhileLoadingMovieDetail() {
        let item = Movie(id: 1, title: "a movie")
        let (sut, loader) = makeSUT(1)
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeMovieDetailLoading(with: .success(item), at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
    }
    
    func test_loadImage_requestsImageDataOnMovieDetailsLoadingSuccessful() {
        let item = Movie(id: 1, title: "a movie", backdropImagePath: "backdropImage")
        let (sut, loader) = makeSUT(1)
        
        sut.loadViewIfNeeded()
        loader.completeMovieDetailLoading(with: .success(item))
        
        XCTAssertEqual(loader.requestedImageURLs, [anyURL().appendingPathComponent(item.backdropImagePath!)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ id: Int) -> (sut: MovieDetailsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewController = MovieDetailsViewController(movieID: id, movieDetailsloader: loader, imageDataLoader: loader) { [unowned self] imagePath in
            self.anyURL().appendingPathComponent(imagePath)
        }
        return (viewController, loader)
    }
    
    private func makeMovieDetails(id: Int, title: String, imagePath: String? = nil, rating: Float? = nil, length: Int? = nil, genres: [String] = [], overview: String = "", backdropImagePath: String? = nil) -> Movie {
        return Movie(id: id, title: title, imagePath: imagePath, rating: rating, length: length, genres: genres, overview: overview, backdropImagePath: backdropImagePath)
    }
    
    private class LoaderSpy: MovieDetailLoader, ImageDataLoader {
        
        // MARK: - MovieDetailLoader
        private var movieDetailsCompletions = [(MovieDetailLoader.Result) -> Void]()
        var movieDetailsLoaderCount: Int {
            return movieDetailsCompletions.count
        }
        
        func load(_ id: Int, completion: @escaping (MovieDetailLoader.Result) -> Void) {
            movieDetailsCompletions.append(completion)
        }
        
        func completeMovieDetailLoading(with result: MovieDetailLoader.Result, at index: Int = 0) {
            movieDetailsCompletions[index](result)
        }
        
        // MARK: - ImageDataLoader
        
        private var imageRequests = [(url: URL, completion: (ImageDataLoader.Result) -> Void)]()
        var requestedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        
        struct TaskSpy: ImageDataLoaderTask {
            func cancel() {
                
            }
        }
        
        func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy()
        }
    }
    
}

private extension MovieDetailsViewController {
    var isShowingLoadingIndicator: Bool {
        movieDetailsView.isLoading
    }
}
