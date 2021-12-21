//
//  HTTPClientSpy.swift
//  ShowTimeCoreTests
//
//  Created by Hoang Nguyen on 21/12/21.
//

import Foundation
import ShowTimeCore

class HTTPClientSpy: HTTPClient {
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
