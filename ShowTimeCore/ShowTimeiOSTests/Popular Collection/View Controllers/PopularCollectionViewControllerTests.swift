//
//  PopularCollectionViewControllerTests.swift
//  ShowTimeiOSTests
//
//  Created by Hoang Nguyen on 22/12/21.
//

import Foundation
import XCTest
import ShowTimeCore
import ShowTimeiOS

class PopularCollectionViewControllerTests: XCTestCase {
    
    func test_load_requestsPopularMoviesFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.popularMoviesLoaderCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.popularMoviesLoaderCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.popularMoviesLoaderCount, 2, "Expected a loading request once view is loaded")
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingMovies() {
        let (sut, loader) = makeSUT()
        let emptyCollection = makePopularCollection()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completePopularMoviesLoading(with: emptyCollection, at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completePopularMoviesLoading(with: emptyCollection, at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadPopularMoviesCompletion_renderSuccessfullyLoadedMovies() {
        let movie1 = makeMovieItem(id: 1, title: "a movie", imagePath: "image1")
        let movie2 = makeMovieItem(id: 2, title: "another movie", imagePath: "image2")
        let collection = makePopularCollection(items: [movie1, movie2], page: 1, totalPages: 1)
        let emptyCollection = makePopularCollection()
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        assertThat(sut, isRendering: emptyCollection)
        
        loader.completePopularMoviesLoading(with: collection)
        
        assertThat(sut, isRendering: collection)
    }
    
    func test_loadPopularMoviesCompletion_doesNotAlterCurrentRenderStateOnError() {
        let movie1 = makeMovieItem(id: 1, title: "a movie", imagePath: "image1")
        let movie2 = makeMovieItem(id: 2, title: "another movie", imagePath: "image2")
        let collection = makePopularCollection(items: [movie1, movie2], page: 1, totalPages: 1)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePopularMoviesLoading(with: collection)
        
        assertThat(sut, isRendering: collection)
        
        sut.simulateUserInitiatedReload()
        loader.completePopularMoviesLoading(with: anyNSError(), at: 1)
        
        assertThat(sut, isRendering: collection)
    }
    
    func test_movieImageView_loadsImageURLWhenVisible() {
        let movie1 = makeMovieItem(id: 1, title: "a movie", imagePath: "image1")
        let movie2 = makeMovieItem(id: 2, title: "another movie", imagePath: "image2")
        let collection = makePopularCollection(items: [movie1, movie2], page: 1, totalPages: 1)
        let url1 = anyURL().appendingPathComponent(movie1.imagePath)
        let url2 = anyURL().appendingPathComponent(movie2.imagePath)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePopularMoviesLoading(with: collection)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateMovieViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [url1], "Expected first image URL request once first view becomes visible")

        sut.simulateMovieViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [url1, url2], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_movieImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let movie1 = makeMovieItem(id: 1, title: "a movie", imagePath: "image1")
        let movie2 = makeMovieItem(id: 2, title: "another movie", imagePath: "image2")
        let collection = makePopularCollection(items: [movie1, movie2], page: 1, totalPages: 1)
        let url1 = anyURL().appendingPathComponent(movie1.imagePath)
        let url2 = anyURL().appendingPathComponent(movie2.imagePath)
        
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completePopularMoviesLoading(with: collection)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")

        sut.simulateMovieViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [url1], "Expected one cancelled image URL request once first image is not visible anymore")

        sut.simulateMovieViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [url1, url2], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    func test_movieImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let movie1 = makeMovieItem(id: 1, title: "a movie", imagePath: "image1")
        let movie2 = makeMovieItem(id: 2, title: "another movie", imagePath: "image2")
        let collection = makePopularCollection(items: [movie1, movie2], page: 1, totalPages: 1)
        
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completePopularMoviesLoading(with: collection)

        let view0 = sut.simulateMovieViewVisible(at: 0)
        let view1 = sut.simulateMovieViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")

        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_movieImageView_rendersImageLoadedFromURL() {
        let movie1 = makeMovieItem(id: 1, title: "a movie", imagePath: "image1")
        let movie2 = makeMovieItem(id: 2, title: "another movie", imagePath: "image2")
        let collection = makePopularCollection(items: [movie1, movie2], page: 1, totalPages: 1)
        
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completePopularMoviesLoading(with: collection)

        let view0 = sut.simulateMovieViewVisible(at: 0)
        let view1 = sut.simulateMovieViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")

        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_movieImageViewRetryButton_isVisibleOnInvalidImageData() {
        let movie1 = makeMovieItem(id: 1, title: "a movie", imagePath: "image1")
        let movie2 = makeMovieItem(id: 2, title: "another movie", imagePath: "image2")
        let collection = makePopularCollection(items: [movie1, movie2], page: 1, totalPages: 1)
        
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completePopularMoviesLoading(with: collection)

        let view = sut.simulateMovieViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")

        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_movieImageViewRetryAction_retriesImageLoad() {
        let movie1 = makeMovieItem(id: 1, title: "a movie", imagePath: "image1")
        let movie2 = makeMovieItem(id: 2, title: "another movie", imagePath: "image2")
        let collection = makePopularCollection(items: [movie1, movie2], page: 1, totalPages: 1)
        let url1 = anyURL().appendingPathComponent(movie1.imagePath)
        let url2 = anyURL().appendingPathComponent(movie2.imagePath)
        
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completePopularMoviesLoading(with: collection)

        let view0 = sut.simulateMovieViewVisible(at: 0)
        let view1 = sut.simulateMovieViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [url1, url2], "Expected two image URL request for the two visible views")

        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [url1, url2], "Expected only two image URL requests before retry action")

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [url1, url2, url1], "Expected third imageURL request after first view retry action")

        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [url1, url2, url1, url2], "Expected fourth imageURL request after second view retry action")
    }
    
    // MARK: - Helper
    
    private func makeSUT() -> (viewController: PopularCollectionViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewController = PopularCollectionUIComposer.compose(loader: loader, imageLoader: loader, baseImageURL: anyURL())
        
        return (viewController, loader)
    }
    
    func assertThat(_ sut: PopularCollectionViewController, isRendering collection: PopularCollection, file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedMovieViews() == collection.itemsCount else {
            return XCTFail("Expected \(collection.itemsCount) movies, got \(sut.numberOfRenderedMovieViews()) instead.", file: file, line: line)
        }

        collection.items.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }

    func assertThat(_ sut: PopularCollectionViewController, hasViewConfiguredFor movie: Movie, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.movieView(at: index)
        
        XCTAssertTrue(view is PopularMovieCell, "Expected \(PopularMovieCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
    }
    
    private func makePopularCollection(items: [Movie] = [], page: Int = 1, totalPages: Int = 1) -> PopularCollection {
        PopularCollection(items: items, page: page, totalPages: totalPages)
    }
    
    private func makeMovieItem(id: Int, title: String, imagePath: String) -> Movie {
        Movie(id: id, title: title, imagePath: imagePath)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }
    
    private class LoaderSpy: PopularMoviesLoader, ImageDataLoader {
        
        // MARK: - PopularMoviesLoader
        private var popularMoviesLoaderCompletions = [(PopularMoviesLoader.Result) -> Void]()
        
        var popularMoviesLoaderCount: Int {
            return popularMoviesLoaderCompletions.count
        }
        
        func load(_ request: PopularMoviesRequest, completion: @escaping (PopularMoviesLoader.Result) -> Void) {
            popularMoviesLoaderCompletions.append(completion)
        }
        
        func completePopularMoviesLoading(with collection: PopularCollection, at index: Int = 0) {
            popularMoviesLoaderCompletions[index](.success(collection))
        }
        
        func completePopularMoviesLoading(with error: NSError, at index: Int = 0) {
            popularMoviesLoaderCompletions[index](.failure(error))
        }
        
        // MARK: - ImageDataLoader
        
        private var imageDataRequests = [(url: URL, completion: (ImageDataLoader.Result) -> Void)]()
        var loadedImageURLs: [URL] {
            imageDataRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        private struct Task: ImageDataLoaderTask {
            var onCancel: (() -> Void)?
            
            init(onCancel: (() -> Void)? = nil) {
                self.onCancel = onCancel
            }
            
            func cancel() {
                onCancel?()
            }
        }
        
        func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
            imageDataRequests.append((url, completion))
            
            return Task() { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageDataRequests[index].completion(.success(imageData))
        }

        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageDataRequests[index].completion(.failure(error))
        }
    }
}


