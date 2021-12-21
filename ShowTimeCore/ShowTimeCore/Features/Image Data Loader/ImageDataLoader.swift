//
//  ImageDataLoader.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 21/12/21.
//

import Foundation

public protocol ImageDataLoaderTask {
    func cancel()
}

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    @discardableResult
    func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask
}
