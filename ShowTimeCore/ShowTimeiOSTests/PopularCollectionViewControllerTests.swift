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
    
}

class PopularCollectionViewController: UICollectionViewController {
    private var popularMoviesLoader: PopularMoviesLoader?
    
    private var collectionModel = [Movie]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    convenience init(popularMoviesLoader: PopularMoviesLoader) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.popularMoviesLoader = popularMoviesLoader
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
        PopularMovieCell()
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
    
    // MARK: - Helper
    
    private func makeSUT() -> (viewController: PopularCollectionViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewController = PopularCollectionViewController(popularMoviesLoader: loader)
        
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
    
    private class LoaderSpy: PopularMoviesLoader {
        
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
}

private extension PopularCollection {
    var itemsCount: Int {
        items.count
    }
}
