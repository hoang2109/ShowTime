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
        case invalidData
    }
    
    private struct RemotePopularMovies: Decodable {
        let page: Int
        let total_pages: Int
        let results: [RemoteMovie]
        
        var toModel: PopularCollection {
            return PopularCollection(items: results.map { $0.toModel }, page: page, totalPages: total_pages)
        }
    }
    
    private struct RemoteMovie: Decodable {
        let id: Int
        let poster_path: String
        let title: String
        
        var toModel: Movie {
            Movie(id: id, title: title, imagePath: poster_path)
        }
    }
    
    init(client: HTTPClient, makeRequest: @escaping (PopularMoviesRequest) -> URLRequest) {
        self.client = client
        self.makeRequest = makeRequest
    }
    
    func load(_ request: PopularMoviesRequest, completion: @escaping (PopularMoviesLoader.Result) -> Void) {
        let request = makeRequest(request)
        client.request(request) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == 200 else {
                    completion(.failure(Error.invalidData))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let item = try decoder.decode(RemotePopularMovies.self, from: data)
                    completion(.success(item.toModel))
                } catch {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func request(_ request: URLRequest, completion: @escaping (Result) -> Void)
}

class RemotePopularMoviesLoaderTests: XCTestCase {
    func test_init_doestNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestCallCount, 0)
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        
        let (url, request) = makePopularMoviesRequest()
        sut.load(request) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        
        let (url, request) = makePopularMoviesRequest()
        sut.load(request) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
        
        sut.load(request) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        let (_, request) = makePopularMoviesRequest()
        
        expect(sut, request: request, toCompleteWithResult: .failure(RemotePopularMoviesLoader.Error.connectivity)) {
            client.complete(with: anyNSError())
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let (url, request) = makePopularMoviesRequest()
        
        [199, 201, 250, 299, 400, 500].enumerated().forEach { (index, statusCode) in
            let non200HTTPResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            expect(sut, request: request, toCompleteWithResult: .failure(RemotePopularMoviesLoader.Error.invalidData)) {
                client.complete(response: non200HTTPResponse, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let (url, request) = makePopularMoviesRequest()
        let invalidData = Data("invalid json".utf8)
        
        expect(sut, request: request, toCompleteWithResult: .failure(RemotePopularMoviesLoader.Error.invalidData)) {
            client.complete(with: invalidData, response: makeHTTPURLResponse(url: url))
        }
    }
    
    func test_load_deliversPopularCollectionOn200HTTPResponseWithJSONEmptyItem() {
        let (sut, client) = makeSUT()
        
        let (url, request) = makePopularMoviesRequest()
        let (empty, json) = makeEmptyPopularCollection()
        let resposne = makeHTTPURLResponse(url: url)
        
        expect(sut, request: request, toCompleteWithResult: .success(empty)) {
            client.complete(with: makeJSONData(json), response: resposne)
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
    
    private func makePopularMoviesRequest(page: Int = 1, language: String = "en-US") -> (url: URL, request: PopularMoviesRequest) {
        let baseURL = makeAnyURL()
        let request = PopularMoviesRequest(page: page, language: language)
        return (request.url(baseURL: baseURL), request)
    }
    
    private func makePopularMoviesURL(request: PopularMoviesRequest) -> URL {
        return APIEndpoint.popularMovies(page: request.page, language: request.language).url(baseURL: makeAnyURL())
    }
    
    private func makeHTTPURLResponse(url: URL, statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    private func makeAnyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func makePopularCollection() -> (item: PopularCollection, json: [String: Any]) {
        let (item1, jsonItem1) = makeMovie(id: 1, title: "a title", imagePath: "image1")
        let (item2, jsonItem2) = makeMovie(id: 2, title: "another title", imagePath: "image2")
        
        let collection = PopularCollection(items: [item1, item2], page: 1, totalPages: 1)
        
        let json: [String: Any] = [
            "page": 1,
            "total_pages": 1,
            "results": [jsonItem1, jsonItem2]
        ]
        
        return (collection, json)
    }
    
    private func makeEmptyPopularCollection() -> (item: PopularCollection, json: [String: Any]) {
        let collection = PopularCollection(items: [], page: 1, totalPages: 1)
        
        let json: [String: Any] = [
            "page": 1,
            "total_pages": 1,
            "results": []
        ]
        
        return (collection, json)
    }
    
    private func makeMovie(id: Int, title: String, imagePath: String) -> (item: Movie, json: [String: Any]) {
        let item = Movie(id: id, title: title, imagePath: imagePath)
        
        let json: [String: Any] = [
            "id": id,
            "title": title,
            "poster_path": imagePath
        ]
        
        return (item, json)
    }
    
    private func makeJSONData(_ json: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: json)
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
        
        func complete(with data: Data = Data(), response: HTTPURLResponse, at index: Int = 0) {
            requests[index].completion(.success((data, response)))
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
