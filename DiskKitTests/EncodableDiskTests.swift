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
        let testFile = MockCodable(id: "ABC")
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try EncodableDisk.store(testFile, to: .documents, as: fileName, path: "some_folder"))
        
        // Then
        guard let loadedFile: MockCodable = try! EncodableDisk.file(withName: fileName, in: .documents, path: "some_folder") else {
            XCTAssert(false)
            return
        }
        
        XCTAssertNotNil(loadedFile)
        XCTAssert(loadedFile == testFile)
    }
    
    func testGivenCodableFile_WhenSaveFile_ThenDiskDataArrayReturnsAllFiles() {
        // Given
        let testFiles = [MockCodable(id: "ABC"), MockCodable(id: "123")]
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try EncodableDisk.store(testFiles[0], to: .documents, as: "example.json", path: "some_folder"))
        XCTAssertNoThrow(try EncodableDisk.store(testFiles[1], to: .documents, as: "example_2.json", path: "some_folder"))
        
        // Then
        guard let loadedFiles: [MockCodable] = try? EncodableDisk.files(in: .documents, path: "some_folder") else {
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
        let testFile = MockCodable(id: "ABC")
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try EncodableDisk.store(testFile, to: .documents, as: "example.json", path: "some_folder"))
        // Then
        XCTAssertTrue(Disk.fileExists(in: .documents, withFileName: fileName, path: "some_folder"))
    }
    
    func testGivenDiskCodableFile_WhenSaveFile_ThenFileLoadReturnsOriginalFile() {
        // Given
        let fileName = "example.json"
        let testFile = MockDiskCodable(id: "ABC")
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try EncodableDisk.store(testFile, to: .documents, as: fileName, path: "some_folder"))
        
        // Then
        guard let loadedFile: MockDiskCodable = try! EncodableDisk.file(withName: fileName, in: .documents, path: "some_folder") else {
            XCTAssert(false)
            return
        }
        
        XCTAssertNotNil(loadedFile)
        XCTAssert(loadedFile == testFile)
    }
    
    func testGivenDiskCodableFile_WhenSaveFile_ThenDiskDataArrayReturnsAllFiles() {
        // Given
        let fileName = "example.json"
        let testFile = MockDiskCodable(id: "ABC")
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try EncodableDisk.store(testFile, to: .documents, as: fileName, path: "some_folder"))
        
        // Then
        guard let loadedFile: MockDiskCodable = try! EncodableDisk.file(withName: fileName, in: .documents, path: "some_folder") else {
            XCTAssert(false)
            return
        }
        
        XCTAssertNotNil(loadedFile)
        XCTAssert(loadedFile == testFile)
    }
    
    func testGivenDiskCodableFile_WhenSaveFile_ThenFileExistsReturnsTrue() {
        // Given
        let fileName = "example.json"
        let testFile = MockDiskCodable(id: "ABC")
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try EncodableDisk.store(testFile, to: .documents, as: "example.json", path: "some_folder"))
        
        // Then
        XCTAssertTrue(Disk.fileExists(in: .documents, withFileName: fileName, path: "some_folder"))
    }
}
