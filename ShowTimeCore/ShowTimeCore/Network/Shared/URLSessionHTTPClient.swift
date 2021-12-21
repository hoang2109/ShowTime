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
    
    public func request(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
