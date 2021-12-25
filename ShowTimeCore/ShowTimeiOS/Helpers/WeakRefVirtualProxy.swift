//
//  WeakRefVirtualProxy.swift
//  ShowTimeiOS
//
//  Created by Hoang Nguyen on 24/12/21.
//

import Foundation

public final class WeakRefVirtualProxy<T: AnyObject> {
    
    private(set) public weak var object: T?
    
    public init(_ object: T) {
        self.object = object
    }
}
