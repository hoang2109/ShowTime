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
}
