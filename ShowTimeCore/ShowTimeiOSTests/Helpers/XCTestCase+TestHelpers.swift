//
//  XCTestCase+TestHelpers.swift
//  ShowTimeiOSTests
//
//  Created by Hoang Nguyen on 27/12/21.
//

import Foundation
import XCTest

extension XCTestCase {
    func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
