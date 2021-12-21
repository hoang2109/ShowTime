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
    
    private final class Task: ImageDataLoaderTask {
        private var completion: ((ImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (ImageDataLoader.Result) -> Void) {
          self.completion = completion
        }

        func complete(with result: ImageDataLoader.Result) {
          completion?(result)
        }

        func cancel() {
          preventFurtherCompletions()
          wrapped?.cancel()
        }

        private func preventFurtherCompletions() {
          completion = nil
        }
    }
    
    func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        let task = Task(completion)

        task.wrapped = client.request(URLRequest(url: url)) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
              .mapError { _ in Error.connectivity }
              .flatMap { (data, response) in
                let isValidResponse = response.statusCode == 200 && !data.isEmpty
                return isValidResponse ? .success(data) : .failure(Error.invalidData)
            })
        }

        return task
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
    
    func test_cancel_doesNotDeliverDataAfterCancellingTask() {
        let url = makeAnyURL()
        let (sut, client) = makeSUT()
        let data = anyData()

        var captureResults: [Any] = []
        let task = sut.load(from: url, completion: { captureResults.append($0) })
        task.cancel()

        client.complete(with: data, response: makeHTTPURLResponse(url: makeAnyURL(), statusCode: 200))
        client.complete(with: anyNSError())

        XCTAssertTrue(captureResults.isEmpty)
    }
    
    func test_doesNotInvokeCompletionOnceInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: ImageDataLoader? = RemoteImageDataLoader(client: client)

        var captureResults = [Any]()
        _ = sut?.load(from: makeAnyURL(), completion: { captureResults.append($0) })
        sut = nil
          
        client.complete(with: anyData(), response: makeHTTPURLResponse(url: makeAnyURL(), statusCode: 200))
        XCTAssertTrue(captureResults.isEmpty)
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
