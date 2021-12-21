//
//  RemoteImageDataLoaderTests.swift
//  ShowTimeCoreTests
//
//  Created by Hoang Nguyen on 21/12/21.
//

import Foundation
import XCTest
import ShowTimeCore

protocol ImageDataLoaderTask {
    func cancel()
}

protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    @discardableResult
    func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask
}

class RemoteImageDataLoader: ImageDataLoader {
    
    private var client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error, Equatable {
        case connectivity
        case invalidData
    }
    
    private struct Task: ImageDataLoaderTask {
        private let onCancel: () -> Void
        
        init(onCancel: @escaping () -> Void) {
            self.onCancel = onCancel
        }
        
        func cancel() {
            onCancel()
        }
    }
    
    func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        let request = URLRequest(url: url)
        let task = client.request(request) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == 200, data.count > 0 else {
                    completion(.failure(Error.invalidData))
                    return
                }
                completion(.success(data))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
        
        return Task {
            task.cancel()
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
        
        _ = sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromRemoteTwice() {
        let url = makeAnyURL()
        let (sut, client) = makeSUT()
        
        _ = sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
        
        _ = sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let error = RemoteImageDataLoader.Error.connectivity
        let (sut, client) = makeSUT()
        
        expect(sut, url: makeAnyURL(), toCompleteWithResult: .failure(error)) {
            client.complete(with: anyNSError())
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        [199, 201, 250, 299, 400, 500].enumerated().forEach { (index, statusCode) in
            let non200HTTPResponse = HTTPURLResponse(url: makeAnyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            expect(sut, url: makeAnyURL(), toCompleteWithResult: .failure(RemoteImageDataLoader.Error.invalidData)) {
                client.complete(response: non200HTTPResponse, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOnSuccessResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, url: makeAnyURL(), toCompleteWithResult: .failure(RemoteImageDataLoader.Error.invalidData)) {
            client.complete(with: Data(), response: makeHTTPURLResponse(url: makeAnyURL(), statusCode: 200))
        }
    }
    
    func test_load_deliversSuccessOnSuccessResponseWithNonEmptyData() {
        let (sut, client) = makeSUT()
        let expected = Data("any data".utf8)
        
        expect(sut, url: makeAnyURL(), toCompleteWithResult: .success(expected)) {
            client.complete(with: expected, response: makeHTTPURLResponse(url: makeAnyURL(), statusCode: 200))
        }
    }
    
    func test_cancel_cancelsPendingTask() {
        let url = makeAnyURL()
        let (sut, client) = makeSUT()

        let task = sut.load(from: url, completion: { _ in })
        XCTAssertTrue(client.cancelledURLs.isEmpty)

        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url])
    }
    
    // MARK: - Helpers
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageDataLoader(client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteImageDataLoader, url: URL, toCompleteWithResult expectedResult: RemoteImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.load(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItem), .success(expectedItem)):
                XCTAssertEqual(receivedItem, expectedItem, file: file, line: line)

            case let (.failure(receivedError as RemoteImageDataLoader.Error), .failure(expectedError as RemoteImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
