//
//  PopularCollectionViewControllerTests.swift
//  ShowTimeiOSTests
//
//  Created by Hoang Nguyen on 22/12/21.
//

import Foundation
import XCTest
import ShowTimeCore

class PopularMovieCell: UICollectionViewCell {
    public var imageContainer = UIView()
    public var movieImageView = UIImageView()
}

class PopularCollectionViewController: UICollectionViewController {
    private var popularMoviesLoader: PopularMoviesLoader?
    private var imageLoader: ImageDataLoader?
    private var makePosterImageURL: ((Movie) -> URL)?
    private var tasks = [IndexPath: ImageDataLoaderTask]()
    
    private var collectionModel = [Movie]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    convenience init(popularMoviesLoader: PopularMoviesLoader, imageLoader: ImageDataLoader, makePosterImageURL: @escaping (Movie) -> URL) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.popularMoviesLoader = popularMoviesLoader
        self.imageLoader = imageLoader
        self.makePosterImageURL = makePosterImageURL
    }
    
    override func viewDidLoad() {
        self.collectionView.refreshControl = UIRefreshControl()
        self.collectionView.refreshControl?.addTarget(self, action: #selector(load), for: UIControl.Event.valueChanged)
        load()
    }
    
    @objc func load() {
        collectionView.refreshControl?.beginRefreshing()
        let request = PopularMoviesRequest(page: 1)
        popularMoviesLoader?.load(request) { [weak self] result in
            if let data = try? result.get() {
                self?.collectionModel = data.items
            }
            
            self?.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionModel.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionModel[indexPath.row]
        let cell = PopularMovieCell()
        if let url = makePosterImageURL?(item) {
            cell.imageContainer.isShimmering = true
            tasks[indexPath] = imageLoader?.load(from: url) { [weak cell] _ in
                cell?.imageContainer.isShimmering = false
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
}

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
    
    // MARK: - Helper
    
    private func makeSUT() -> (viewController: PopularCollectionViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewController = PopularCollectionViewController(popularMoviesLoader: loader, imageLoader: loader) { [unowned self] movie in
            self.anyURL().appendingPathComponent(movie.imagePath)
        }
        
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

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIRefreshControl {
    func simulateRefreshing() {
        simulate(event: .valueChanged)
    }
}

private extension PopularCollectionViewController {
    var isShowingLoadingIndicator: Bool {
        return collectionView.refreshControl!.isRefreshing
    }
    
    func simulateUserInitiatedReload() {
        self.collectionView.refreshControl?.simulateRefreshing()
    }
    
    func numberOfRenderedMovieViews() -> Int {
        self.collectionView.numberOfItems(inSection: 0)
    }
    
    func movieView(at index: Int) -> UICollectionViewCell? {
        let ds = collectionView.dataSource
        let indexPath = IndexPath(row: index, section: 0)
        return ds?.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    @discardableResult
    func simulateMovieViewVisible(at index: Int) -> PopularMovieCell? {
        movieView(at: index) as? PopularMovieCell
    }
    
    func simulateMovieViewNotVisible(at index: Int) {
        let view = movieView(at: index)
        let dl = collectionView.delegate
        let indexPath = IndexPath(row: index, section: 0)
        dl?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: indexPath)
    }
}

private extension PopularMovieCell {
    var isShowingImageLoadingIndicator: Bool {
        imageContainer.isShimmering
    }
}

private extension PopularCollection {
    var itemsCount: Int {
        items.count
    }
}

import UIKit

extension UIView {
    public var isShimmering: Bool {
        set {
            if newValue {
                startShimmering()
            } else {
                stopShimmering()
            }
        }

        get {
            return layer.mask?.animation(forKey: shimmerAnimationKey) != nil
        }
    }

    private var shimmerAnimationKey: String {
        return "shimmer"
    }

    private func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.75).cgColor
        let width = bounds.width
        let height = bounds.height

        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient

        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.25
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }

    private func stopShimmering() {
        layer.mask = nil
    }
}
