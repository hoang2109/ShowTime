//
//  AuthenticatedHTTPClientDecorator.swift
//  ShowTimeApp
//
//  Created by Hoang Nguyen on 25/12/21.
//

import Foundation
import ShowTimeCore

public class AuthenticatedHTTPClientDecorator: HTTPClient {
    public typealias Result = HTTPClient.Result
    
    private let decoratee: HTTPClient
    private let apiKey: String
    
    public init(decoratee: HTTPClient, apiKey: String) {
        self.decoratee = decoratee
        self.apiKey = apiKey
    }
    
    public func request(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        let signedRequest = signAPIKey(request)
        return decoratee.request(signedRequest, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(body): completion(.success(body))
            case let .failure(error): completion(.failure(error))
            }
        })
    }
    
    private func signAPIKey(_ request: URLRequest) -> URLRequest {
        guard let requestURL = request.url, var urlComponents = URLComponents(string: requestURL.absoluteString) else { return request }
        
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        queryItems.append(.init(name: "api_key", value: apiKey))
        urlComponents.queryItems = queryItems
        
        guard let authenticatedRequestURL = urlComponents.url else { return request }
        
        var signedRequest = request
        signedRequest.url = authenticatedRequestURL
        return signedRequest
    }
}
