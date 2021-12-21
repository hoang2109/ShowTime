//
//  RemoteImageDataLoaderTests.swift
//  ShowTimeCoreTests
//
//  Created by Hoang Nguyen on 21/12/21.
//

import Foundation
import XCTest
import ShowTimeCore

protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void)
}

class RemoteImageDataLoader: ImageDataLoader {
    
    private var client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) {
        let request = URLRequest(url: url)
        client.request(request) { result in
            
        }
    }
}

class RemoteImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromRemote() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let url = makeAnyURL()
        let (sut, client) = makeSUT()
        
        sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromRemoteTwice() {
        let url = makeAnyURL()
        let (sut, client) = makeSUT()
        
        sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
        
        sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageDataLoader(client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
}
