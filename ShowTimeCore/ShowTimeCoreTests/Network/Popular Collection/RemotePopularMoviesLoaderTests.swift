//
//  RemotePopularMoviesLoaderTests.swift
//  ShowTimeCoreTests
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation
import XCTest
import ShowTimeCore

class RemotePopularMoviesLoader: PopularMoviesLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(_ request: PopularMoviesRequest, completion: (PopularMoviesLoader.Result) -> Void) {
        
    }
}

protocol HTTPClient {
    
}

class RemotePopularMoviesLoaderTests: XCTestCase {
    func test_init_doestNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let _ = RemotePopularMoviesLoader(client: client)
        
        XCTAssertEqual(client.requestCallCount, 0)
    }
    
    // MARK: - Helpers
    private class HTTPClientSpy: HTTPClient {
        private(set) var requestCallCount = 0
    }
}

