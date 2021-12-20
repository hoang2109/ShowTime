//
//  RemotePopularMoviesLoader.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation

public class RemotePopularMoviesLoader: PopularMoviesLoader {
    private let client: HTTPClient
    private let makeRequest: (PopularMoviesRequest) -> URLRequest
    
    public enum Error: Swift.Error, Equatable {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, makeRequest: @escaping (PopularMoviesRequest) -> URLRequest) {
        self.client = client
        self.makeRequest = makeRequest
    }
    
    public func load(_ request: PopularMoviesRequest, completion: @escaping (PopularMoviesLoader.Result) -> Void) {
        let request = makeRequest(request)
        client.request(request) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(PopularMoviesMapper.map(data: data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
