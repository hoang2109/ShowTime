//
//  URLSessionHTTPClient.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 21/12/21.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let urlSession: URLSession
    
    public init(_ urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    private struct Task: HTTPClientTask {
        let sessionTask: URLSessionTask
        
        init(sessionTask: URLSessionDataTask) {
            self.sessionTask = sessionTask
        }
        
        func cancel() {
            sessionTask.cancel()
        }
    }
    
    public func request(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
        task.resume()
        
        return Task(sessionTask: task)
    }
}
