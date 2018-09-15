//
//  PackagableDiskTests.swift
//  DiskKitTests
//
//  Created by Jacob Sikorski on 2018-09-10.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import XCTest
@testable import DiskKit

class PackagableDiskTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let _ = try? Disk.clear(.documents)
    }
    
    override func tearDown() {
        let _ = try? Disk.clear(.documents)
        super.tearDown()
    }
    
    func testGivenPackagableFile_WhenSaveFile_ThenFileLoadReturnsOriginalFile() {
        // Given
        let fileName = "example.package"
        
        let testFile = MockPackage(
            codable: MockCodable(id: "CODABLE_ABC"),
            diskCodable: MockDiskCodable(id: "DISK_CODABLE_ABC")
        )
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try PackagableDisk.store(testFile, to: .documents, withName: fileName, path: "some_folder"))
        
        // Then
        guard let loadedFile: MockPackage = try! PackagableDisk.package(withName: fileName, in: .documents, path: "some_folder") else {
            XCTAssert(false)
            return
        }
        
        XCTAssertNotNil(loadedFile)
        XCTAssert(loadedFile == testFile)
    }
    
    func testGivenCodableFile_WhenSaveFile_ThenDiskDataArrayReturnsAllFiles() {
        // Given
        let testFiles = [
            MockPackage(
                codable: MockCodable(id: "CODABLE_ABC"),
                diskCodable: MockDiskCodable(id: "DISK_CODABLE_ABC")
            ),
            MockPackage(
                codable: MockCodable(id: "CODABLE_123"),
                diskCodable: MockDiskCodable(id: "DISK_CODABLE_123")
            )
        ]

        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try PackagableDisk.store(testFiles[0], to: .documents, withName: "example_2.package", path: "some_folder"))
        XCTAssertNoThrow(try PackagableDisk.store(testFiles[1], to: .documents, withName: "example_1.package", path: "some_folder"))

        // Then
        guard let loadedFiles: [MockPackage] = try? PackagableDisk.packages(in: .documents, path: "some_folder") else {
            XCTAssert(false)
            return
        }

        XCTAssert(loadedFiles.count == 2)
        XCTAssert(loadedFiles[0] == testFiles[0])
        XCTAssert(loadedFiles[1] == testFiles[1])
    }
    
    func testGivenCodableFile_WhenSaveFile_ThenFileExistsReturnsTrue() {
        // Given
        let fileName = "example.package"
        
        let testFile = MockPackage(
            codable: MockCodable(id: "CODABLE_ABC"),
            diskCodable: MockDiskCodable(id: "DISK_CODABLE_ABC")
        )
        
        // When
        XCTAssertNoThrow(try PackagableDisk.store(testFile, to: .documents, withName: fileName))
        
        // Then
        XCTAssertTrue(Disk.fileExists(in: .documents, withFileName: fileName))
        
    }
}
