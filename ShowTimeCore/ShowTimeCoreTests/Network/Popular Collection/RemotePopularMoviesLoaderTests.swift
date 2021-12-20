//
//  RemotePopularMoviesLoaderTests.swift
//  ShowTimeCoreTests
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation
import XCTest
import ShowTimeCore

public enum APIEndpoint {
    case popularMovies(page: Int, language: String)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .popularMovies(page, language):
            let requestURL = baseURL
              .appendingPathComponent("3")
              .appendingPathComponent("movie")

            var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = [
              URLQueryItem(name: "language", value: language),
              URLQueryItem(name: "page", value: "\(page)")
            ]
            return urlComponents?.url ?? requestURL
        }
    }
}

class RemotePopularMoviesLoader: PopularMoviesLoader {
    private let client: HTTPClient
    private let makeRequest: (PopularMoviesRequest) -> URLRequest
    
    public enum Error: Swift.Error, Equatable {
        case connectivity
    }
    
    init(client: HTTPClient, makeRequest: @escaping (PopularMoviesRequest) -> URLRequest) {
        self.client = client
        self.makeRequest = makeRequest
    }
    
    func load(_ request: PopularMoviesRequest, completion: @escaping (PopularMoviesLoader.Result) -> Void) {
        let request = makeRequest(request)
        client.request(request) { _ in
            completion(.failure(Error.connectivity))
        }
    }
}

protocol HTTPClient {
    typealias Result = Swift.Result<Data, Error>
    
    func request(_ request: URLRequest, completion: @escaping (Result) -> Void)
}

class RemotePopularMoviesLoaderTests: XCTestCase {
    func test_init_doestNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestCallCount, 0)
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        
        let request = makePopularMoviesRequest()
        sut.load(request) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [request.url(baseURL: makeAnyURL())])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        
        let request = makePopularMoviesRequest()
        sut.load(request) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [request.url(baseURL: makeAnyURL())])
        
        sut.load(request) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [request.url(baseURL: makeAnyURL()), request.url(baseURL: makeAnyURL())])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        let request = makePopularMoviesRequest()
        
        expect(sut, request: request, toCompleteWithResult: .failure(RemotePopularMoviesLoader.Error.connectivity)) {
            client.complete(with: anyNSError())
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: RemotePopularMoviesLoader, client: HTTPClientSpy) {
        let baseURL = makeAnyURL()
        let client = HTTPClientSpy()
        let sut = RemotePopularMoviesLoader(client: client) { request in
            let url = APIEndpoint.popularMovies(page: request.page, language: request.language).url(baseURL: baseURL)
            return URLRequest(url: url)
        }
        return (sut, client)
    }
    
    private func expect(_ sut: RemotePopularMoviesLoader, request: PopularMoviesRequest, toCompleteWithResult expectedResult: RemotePopularMoviesLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load(request) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItem), .success(expectedItem)):
                XCTAssertEqual(receivedItem, expectedItem, file: file, line: line)

            case let (.failure(receivedError as RemotePopularMoviesLoader.Error), .failure(expectedError as RemotePopularMoviesLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makePopularMoviesRequest(page: Int = 1, language: String = "en-US") -> PopularMoviesRequest {
        PopularMoviesRequest(page: page, language: language)
    }
    
    private func makePopularMoviesURL(request: PopularMoviesRequest) -> URL {
        return APIEndpoint.popularMovies(page: request.page, language: request.language).url(baseURL: makeAnyURL())
    }
    
    private func makeAnyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var requests = [(request: URLRequest, completion: (HTTPClient.Result) -> Void)]()
        
        var requestedURLs: [URL?] {
            requests.map {
                $0.0.url
            }
        }
        var requestCallCount: Int {
            requests.count
        }
        
        func request(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
            requests.append((request, completion))
        }
        
        func complete(with error: NSError, at index: Int = 0) {
            requests[index].completion(.failure(error))
        }
    }
}

private extension PopularMoviesRequest {
    func url(baseURL: URL) -> URL {
        return APIEndpoint.popularMovies(page: page, language: language).url(baseURL: baseURL)
    }
}

private extension Result {
    var error: Failure? {
        switch self {
        case let .failure(error):
            return error
        case .success:
            return nil
        }
    }
}
