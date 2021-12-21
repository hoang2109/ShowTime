//
//  URLSessionClientTests.swift
//  ShowTimeCoreTests
//
//  Created by Hoang Nguyen on 21/12/21.
//

import Foundation
import XCTest
import ShowTimeCore

class URLSessionHTTPClient: HTTPClient {
    
    private let urlSession: URLSession
    
    init(_ urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func request(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        urlSession.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_request_failsOnRequestError() {
        let expected = anyNSError()
        URLProtocolStub.stub(data: nil, response: nil, error: expected)
        let sut = URLSessionHTTPClient()
        let request = URLRequest(url: makeAnyURL())
        
        let exp = expectation(description: "Waiting for completion")
        
        var received: HTTPClient.Result?
        sut.request(request) { result in
            received = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual((received?.error as NSError?)?.code, expected.code)
        XCTAssertEqual((received?.error as NSError?)?.domain, expected.domain)
    }
    
    
    // MARK: - Helpers
    
    
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
