//
//  DiskTests.swift
//  DiskKitTests
//
//  Created by Jacob Sikorski on 2018-09-10.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import XCTest
@testable import DiskKit

class DiskTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let _ = try? Disk.clear(.documents)
    }
    
    override func tearDown() {
        let _ = try? Disk.clear(.documents)
        super.tearDown()
    }
    
    func testGivenDiskData_WhenSaveFile_ThenFileLoadReturnsOriginalFile() {
        // Given
        let fileName = "example.json"
        let testFile = MockCodable(id: "ABC")
        
        guard let diskData = try? DiskData(file: testFile, name: fileName) else {
            XCTAssert(false)
            return
        }
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try Disk.store(diskData, to: .documents, path: "some_folder"))
        
        // Then
        guard let loadedDiskData = try! Disk.diskData(withName: fileName, in: .documents, path: "some_folder") else {
            XCTAssert(false)
            return
        }
        
        guard let loadedFile: MockCodable = try! loadedDiskData.decode() else {
            XCTAssert(false)
            return
        }
        
        XCTAssertNotNil(loadedDiskData)
        XCTAssertNotNil(loadedFile)
        XCTAssert(loadedFile == testFile)
    }
    
    func testGivenDiskData_WhenSaveFile_ThenDiskDataArrayReturnsAllFiles() {
        // Given
        let testFiles = [MockCodable(id: "ABC"), MockCodable(id: "123")]
        
        let diskDataArray = testFiles.enumerated().compactMap({
            return try? DiskData(file: $0.element, name: "example_\($0.offset)")
        })
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try Disk.store(diskDataArray[0], to: .documents, path: "some_folder"))
        XCTAssertNoThrow(try Disk.store(diskDataArray[1], to: .documents, path: "some_folder"))
        
        // Then
        guard let loadedDiskDataArray = try? Disk.diskDataArray(in: .documents, path: "some_folder") else {
            XCTAssert(false)
            return
        }
        
        let loadedFiles: [MockCodable] = loadedDiskDataArray.compactMap({
            return try? $0.decode()
        })
        
        XCTAssert(loadedDiskDataArray.count == 2)
        XCTAssert(loadedFiles.count == 2)
        XCTAssert(loadedFiles[0] == testFiles[1])
        XCTAssert(loadedFiles[1] == testFiles[0])
    }
    
    func testGivenDiskData_WhenSaveFile_ThenFileExistsReturnsTrue() {
        // Given
        let fileName = "example.json"
        let testFile = MockCodable(id: "ABC")
        
        guard let diskData = try? DiskData(file: testFile, name: fileName) else {
            XCTAssert(false)
            return
        }
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try Disk.store(diskData, to: .documents, path: "some_folder"))
        
        // Then
        XCTAssertTrue(Disk.fileExists(in: .documents, withFileName: fileName, path: "some_folder"))
    }
    
    func testRemovingPathInDirectory() {
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try Disk.remove(path: "some_folder", in: .documents))
    }
}
