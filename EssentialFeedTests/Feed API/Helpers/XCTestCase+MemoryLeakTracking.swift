//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeed
//
//  Created by Felipe Filgueira on 6/12/25.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject ,file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
