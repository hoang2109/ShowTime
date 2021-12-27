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
    
    func test_loadMovieDetailCompletion_renderSuccessfullyLoadedMovie() {
        let item = Movie(id: 1, title: "a movie", imagePath: "imagePath", rating: 8, length: 100, genres: ["Action", "Adventure"], overview: "Overview", backdropImagePath: "backdropImagePath")
        let (sut, loader) = makeSUT(1)
        
        sut.loadViewIfNeeded()
        loader.completeMovieDetailLoading(with: .success(item))
        
        XCTAssertEqual(sut.titleText, item.title)
        XCTAssertEqual(sut.overViewText, item.overview)
        XCTAssertEqual(sut.metaText, "1 hr, 40 min | Action, Adventure")
    }
    
    func test_loadImageCompletion_renderSuccessfullyLoadedImage() {
        let item = Movie(id: 1, title: "a movie", imagePath: "imagePath", rating: 8, length: 100, genres: ["Action", "Adventure"], overview: "Overview", backdropImagePath: "backdropImagePath")
        let imageData = UIImage.make(withColor: .blue).pngData()!
        let (sut, loader) = makeSUT(1)
        
        sut.loadViewIfNeeded()
        loader.completeMovieDetailLoading(with: .success(item))
        loader.completeImageDataLoading(with: .success(imageData))
        
        XCTAssertEqual(sut.renderedImage, imageData)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(_ id: Int, file: StaticString = #file, line: UInt = #line) -> (sut: MovieDetailsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = MovieDetailsViewController(movieID: id, movieDetailsloader: loader, imageDataLoader: loader) { [unowned self] imagePath in
            self.anyURL().appendingPathComponent(imagePath)
        }
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
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
        
        func completeImageDataLoading(with result: ImageDataLoader.Result, at index: Int = 0) {
            imageRequests[index].completion(result)
        }
    }
    
}

private extension MovieDetailsViewController {
    var isShowingLoadingIndicator: Bool {
        movieDetailsView.isLoading
    }
    
    var titleText: String? {
        movieDetailsView.titleLabel.text
    }
    
    var metaText: String? {
        movieDetailsView.metaLabel.text
    }
    
    var overViewText: String? {
        movieDetailsView.overviewLabel.text
    }
    
    var renderedImage: Data? {
        movieDetailsView.bakcgroundImageView.image?.pngData()
    }
}
