//
//  HTTPClient.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func request(_ request: URLRequest, completion: @escaping (Result) -> Void)
}
