//
//  ExampleTests.swift
//  ExampleTests
//
//  Created by Jacob Sikorski on 2018-09-26.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import XCTest
@testable import Example

class ExampleTests: XCTestCase {

    override func setUp() {
        DiskUtility.clearDocuments()
    }
    
    override func tearDown() {
        DiskUtility.clearDocuments()
    }
    
    func testSavingPackages() {
        // Given
        let filename = "example.package"
        var article = Article()
        article.details.body = "Some body"
        article.author.name = "John Smith"
        let baseUrl = Article.baseUrl
        let fileUrl = baseUrl.appendingPathComponent(filename)
        
        // When
        XCTAssertNoThrow(try article.save(to: fileUrl, from: nil))
        
        // Then
        do {
            let loaded = try Article.loadAll(from: baseUrl)
            XCTAssert(loaded.count == 1)
            
            if loaded.count == 1 {
                XCTAssert(article.details.body == loaded[0].details.body)
                XCTAssert(article.author.name == loaded[0].author.name)
            }
        } catch {
            XCTAssert(false)
        }
    }
}
