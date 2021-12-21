//
//  RemoteImageDataLoader.swift
//  ShowTimeCore
//
//  Created by Hoang Nguyen on 21/12/21.
//

import Foundation

public final class RemoteImageDataLoader: ImageDataLoader {
    
    private var client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error, Equatable {
        case connectivity
        case invalidData
    }
    
    private final class Task: ImageDataLoaderTask {
        private var completion: ((ImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (ImageDataLoader.Result) -> Void) {
          self.completion = completion
        }

        func complete(with result: ImageDataLoader.Result) {
          completion?(result)
        }

        func cancel() {
          preventFurtherCompletions()
          wrapped?.cancel()
        }

        private func preventFurtherCompletions() {
          completion = nil
        }
    }
    
    public func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        let task = Task(completion)

        task.wrapped = client.request(URLRequest(url: url)) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
              .mapError { _ in Error.connectivity }
              .flatMap { (data, response) in
                let isValidResponse = response.statusCode == 200 && !data.isEmpty
                return isValidResponse ? .success(data) : .failure(Error.invalidData)
            })
        }

        return task
    }
}
