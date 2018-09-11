//
//  EncodableDiskTests.swift
//  DiskKitTests
//
//  Created by Jacob Sikorski on 2018-09-10.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import XCTest
@testable import DiskKit

class EncodableDiskTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let _ = try? Disk.clear(.documents)
    }
    
    override func tearDown() {
        let _ = try? Disk.clear(.documents)
        super.tearDown()
    }
    
    func testGivenCodableFile_WhenSaveFile_ThenFileLoadReturnsOriginalFile() {
        // Given
        let fileName = "example.json"
        let testFile = TestCodable(id: "ABC")
        
        // When
        XCTAssertNoThrow(try EncodableDisk.store(testFile, to: .documents, as: fileName))
        
        // Then
        guard let loadedFile: TestCodable = try! EncodableDisk.file(withName: fileName, in: .documents) else {
            XCTAssert(false)
            return
        }
        
        XCTAssertNotNil(loadedFile)
        XCTAssert(loadedFile == testFile)
    }
    
    func testGivenCodableFile_WhenSaveFile_ThenDiskDataArrayReturnsAllFiles() {
        // Given
        let testFiles = [TestCodable(id: "ABC"), TestCodable(id: "123")]
        
        // When
        
        XCTAssertNoThrow(try EncodableDisk.store(testFiles[0], to: .documents, as: "example.json"))
        XCTAssertNoThrow(try EncodableDisk.store(testFiles[1], to: .documents, as: "example_2.json"))
        
        // Then
        guard let loadedFiles: [TestCodable] = try? EncodableDisk.files(in: .documents) else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(loadedFiles.count == 2)
        XCTAssert(loadedFiles[0] == testFiles[1])
        XCTAssert(loadedFiles[1] == testFiles[0])
    }
    
    func testGivenCodableFile_WhenSaveFile_ThenFileExistsReturnsTrue() {
        // Given
        let fileName = "example.json"
        let testFile = TestCodable(id: "ABC")
        
        // When
        XCTAssertNoThrow(try EncodableDisk.store(testFile, to: .documents, as: "example.json"))
        
        // Then
        XCTAssertTrue(Disk.fileExists(in: .documents, withFileName: fileName))
    }
    
    func testGivenDiskCodableFile_WhenSaveFile_ThenFileLoadReturnsOriginalFile() {
        // Given
        let fileName = "example.json"
        let testFile = TestDiskCodable(id: "ABC")
        
        // When
        XCTAssertNoThrow(try EncodableDisk.store(testFile, to: .documents, as: fileName))
        
        // Then
        guard let loadedFile: TestDiskCodable = try! EncodableDisk.file(withName: fileName, in: .documents) else {
            XCTAssert(false)
            return
        }
        
        XCTAssertNotNil(loadedFile)
        XCTAssert(loadedFile == testFile)
    }
    
    func testGivenDiskCodableFile_WhenSaveFile_ThenDiskDataArrayReturnsAllFiles() {
        // Given
        let fileName = "example.json"
        let testFile = TestDiskCodable(id: "ABC")
        
        // When
        XCTAssertNoThrow(try EncodableDisk.store(testFile, to: .documents, as: fileName))
        
        // Then
        guard let loadedFile: TestDiskCodable = try! EncodableDisk.file(withName: fileName, in: .documents) else {
            XCTAssert(false)
            return
        }
        
        XCTAssertNotNil(loadedFile)
        XCTAssert(loadedFile == testFile)
    }
    
    func testGivenDiskCodableFile_WhenSaveFile_ThenFileExistsReturnsTrue() {
        // Given
        let fileName = "example.json"
        let testFile = TestDiskCodable(id: "ABC")
        
        // When
        XCTAssertNoThrow(try EncodableDisk.store(testFile, to: .documents, as: "example.json"))
        
        // Then
        XCTAssertTrue(Disk.fileExists(in: .documents, withFileName: fileName))
    }
}
