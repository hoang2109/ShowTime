//
//  MainQueueDispatchDecorator.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 25/12/21.
//

import Foundation
import ShowTimeCore

public final class MainQueueDispatchDecorator<T> {
    
    private(set) public var decoratee: T
    
    public init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    public func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: PopularMoviesLoader where T == PopularMoviesLoader {
    public func load(_ request: PopularMoviesRequest, completion: @escaping (PopularMoviesLoader.Result) -> Void) {
        decoratee.load(request, completion: { [weak self] result in
            self?.dispatch { completion(result) }
        })
    }
}

extension MainQueueDispatchDecorator: ImageDataLoader where T == ImageDataLoader {
    public func load(from imageURL: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        decoratee.load(from: imageURL, completion: { [weak self] result in
            self?.dispatch { completion(result) }
        })
    }
}

extension MainQueueDispatchDecorator: MovieDetailLoader where T == MovieDetailLoader {
    public func load(_ id: Int, completion: @escaping (MovieDetailLoader.Result) -> Void) {
        decoratee.load(id) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
