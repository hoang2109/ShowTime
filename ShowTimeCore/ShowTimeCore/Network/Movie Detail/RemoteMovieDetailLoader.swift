//
//  RemoteMovieDetailLoader.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 26/12/21.
//

import Foundation

public class RemoteMovieDetailLoader: MovieDetailLoader {
    private let client: HTTPClient
    private let makeRequest: (Int) -> URLRequest
    
    public enum Error: Swift.Error, Equatable {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, makeRequest: @escaping (Int) -> URLRequest) {
        self.client = client
        self.makeRequest = makeRequest
    }
    
    public func load(_ id: Int, completion: @escaping (MovieDetailLoader.Result) -> Void) {
        let request = makeRequest(id)
        client.request(request) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(MovieDetailMapper.map(data: data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
