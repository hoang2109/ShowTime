//
//  XCTestCase+TestHelpers.swift
//  ShowTimeCoreTests
//
//  Created by Hoang Nguyen on 20/12/21.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

extension Result {
    var error: Failure? {
        switch self {
        case let .failure(error):
            return error
        case .success:
            return nil
        }
    }
}

func makeJSONData(_ json: [String: Any]) -> Data {
    return try! JSONSerialization.data(withJSONObject: json)
}

func makeHTTPURLResponse(url: URL, statusCode: Int = 200) -> HTTPURLResponse {
    HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

func makeAnyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    Data("any data".utf8)
}
