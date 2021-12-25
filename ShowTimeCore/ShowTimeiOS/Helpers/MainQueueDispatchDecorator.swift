//
//  MainQueueDispatchDecorator.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 25/12/21.
//

import Foundation

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
