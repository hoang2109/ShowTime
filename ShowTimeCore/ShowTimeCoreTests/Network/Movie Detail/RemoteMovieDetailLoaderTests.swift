//
//  RemoteMovieDetailLoader.swift
//  ShowTimeCoreTests
//
//  Created by Hoang Nguyen on 26/12/21.
//

import Foundation
import ShowTimeCore
import XCTest

class RemoteMovieDetailLoaderTests: XCTestCase {
    func test_init_doestNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestCallCount, 0)
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        
        let url = makeURL()
        sut.load(1) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        
        let url = makeURL()
        sut.load(1) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
        
        sut.load(1) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, movieID: 1, toCompleteWithResult: .failure(RemoteMovieDetailLoader.Error.connectivity)) {
            client.complete(with: anyNSError())
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let url = makeURL()
        
        [199, 201, 250, 299, 400, 500].enumerated().forEach { (index, statusCode) in
            let non200HTTPResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            expect(sut, movieID: 1, toCompleteWithResult: .failure(RemoteMovieDetailLoader.Error.invalidData)) {
                client.complete(response: non200HTTPResponse, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let invalidData = Data("invalid json".utf8)
        let url = makeURL()
        
        expect(sut, movieID: 1, toCompleteWithResult: .failure(RemoteMovieDetailLoader.Error.invalidData)) {
            client.complete(with: invalidData, response: makeHTTPURLResponse(url: url))
        }
    }
    
    func test_load_deliversMovieDetailOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let url = makeURL()
        let (movie, json) = makeMovie(id: 1, title: "a title", imagePath: "image", rating: 7, length: 100, genres: ["comedy"], overview: "overview", backdropImagePath: "backdropImagePath")
        let resposne = makeHTTPURLResponse(url: url)
        
        expect(sut, movieID: 1, toCompleteWithResult: .success(movie)) {
            client.complete(with: makeJSONData(json), response: resposne)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let url = makeURL()
        var sut: RemoteMovieDetailLoader? = RemoteMovieDetailLoader(client: client) { request in
            return URLRequest(url: url)
        }
        
        var captureResults = [RemoteMovieDetailLoader.Result]()
        sut?.load(1, completion: { result in
            captureResults.append(result)
        })
        
        sut = nil
        client.complete(response: makeHTTPURLResponse(url: url))
        
        XCTAssertTrue(captureResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteMovieDetailLoader, client: HTTPClientSpy) {
        let baseURL = makeAnyURL()
        let client = HTTPClientSpy()
        let sut = RemoteMovieDetailLoader(client: client) { id in
            let url = APIEndpoint.movieDetail(id: id).url(baseURL: baseURL)
            return URLRequest(url: url)
        }
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteMovieDetailLoader, movieID: Int, toCompleteWithResult expectedResult: RemoteMovieDetailLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load(movieID) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItem), .success(expectedItem)):
                XCTAssertEqual(receivedItem, expectedItem, file: file, line: line)

            case let (.failure(receivedError as RemoteMovieDetailLoader.Error), .failure(expectedError as RemoteMovieDetailLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeURL(_ id: Int = 1) -> URL {
        return APIEndpoint.movieDetail(id: id).url(baseURL: makeAnyURL())
    }
    
    private func makeMovie(id: Int, title: String, imagePath: String, rating: Float, length: Int, genres: [String], overview: String, backdropImagePath: String) -> (item: Movie, json: [String: Any]) {
        let item = Movie(id: id, title: title, imagePath: imagePath, rating: rating, length: length, genres: genres, overview: overview, backdropImagePath: backdropImagePath)
        
        let json: [String: Any] = [
            "id": id,
            "title": title,
            "poster_path": imagePath,
            "backdrop_path": backdropImagePath,
            "vote_average": rating,
            "runtime": length,
            "genres": genres.map {
                ["name": $0]
            },
            "overview": overview
        ]
        
        return (item, json)
    }
}
