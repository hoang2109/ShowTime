//
//  PopularCollectionViewControllerTests.swift
//  ShowTimeiOSTests
//
//  Created by Hoang Nguyen on 22/12/21.
//

import Foundation
import XCTest
import ShowTimeCore

class PopularCollectionViewController: UICollectionViewController {
    private var popularMoviesLoader: PopularMoviesLoader?
    
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
        popularMoviesLoader?.load(request) { [weak self] _ in
            self?.collectionView.refreshControl?.endRefreshing()
        }
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
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completePopularMoviesLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completePopularMoviesLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    // MARK: - Helper
    
    private func makeSUT() -> (viewController: PopularCollectionViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewController = PopularCollectionViewController(popularMoviesLoader: loader)
        
        return (viewController, loader)
    }
    
    private class LoaderSpy: PopularMoviesLoader {
        
        private var popularMoviesLoaderCompletions = [(PopularMoviesLoader.Result) -> Void]()
        
        var popularMoviesLoaderCount: Int {
            return popularMoviesLoaderCompletions.count
        }
        
        func load(_ request: PopularMoviesRequest, completion: @escaping (PopularMoviesLoader.Result) -> Void) {
            popularMoviesLoaderCompletions.append(completion)
        }
        
        func completePopularMoviesLoading(at index: Int = 0) {
            popularMoviesLoaderCompletions[index](.success(PopularCollection(items: [], page: 1, totalPages: 1)))
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
}
