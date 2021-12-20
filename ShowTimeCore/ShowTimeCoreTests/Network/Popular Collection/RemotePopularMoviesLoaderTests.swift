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
    
    init(client: HTTPClient, makeRequest: @escaping (PopularMoviesRequest) -> URLRequest) {
        self.client = client
        self.makeRequest = makeRequest
    }
    
    func load(_ request: PopularMoviesRequest, completion: @escaping (PopularMoviesLoader.Result) -> Void) {
        let request = makeRequest(request)
        client.request(request) { _ in
            
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
        
        XCTAssertEqual(client.urlRequests, [request.url(baseURL: makeAnyURL())])
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
    
    private func makePopularMoviesRequest(page: Int = 1, language: String = "en-US") -> PopularMoviesRequest {
        PopularMoviesRequest(page: page, language: language)
    }
    
    private func makePopularMoviesURL(request: PopularMoviesRequest) -> URL {
        return APIEndpoint.popularMovies(page: request.page, language: request.language).url(baseURL: makeAnyURL())
    }
    
    private func makeAnyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private class HTTPClientSpy: HTTPClient {
        private(set) var urlRequests = [URL?]()
        private(set) var requestCallCount = 0
        
        func request(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
            urlRequests.append(request.url)
        }
    }
}

private extension PopularMoviesRequest {
    func url(baseURL: URL) -> URL {
        return APIEndpoint.popularMovies(page: page, language: language).url(baseURL: baseURL)
    }
}

