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
        let filename = "example.directory"
        let testFile = MockPackage(id: "ABC")
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try PackagableDisk.store(testFile, to: .documents, as: filename, path: "some_folder"))
        
        // Then
        do {
            guard let loadedFile: MockPackage = try PackagableDisk.package(withName: filename, in: .documents, path: "some_folder") else {
                XCTAssert(false)
                return
            }
            
            XCTAssertNotNil(loadedFile)
            XCTAssert(loadedFile == testFile)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testGivenPackagableFile_WhenSaveFile_ThenPackagableDiskReturnsAllFiles() {
        // Given
        let testFiles = [
            MockPackage(id: "ABC"),
            MockPackage(id: "123")
        ]

        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder/sub_folder", in: .documents))
        XCTAssertNoThrow(try PackagableDisk.store(testFiles[0], to: .documents, as: "example_2.package", path: "some_folder"))
        XCTAssertNoThrow(try PackagableDisk.store(testFiles[1], to: .documents, as: "example_1.package", path: "some_folder/sub_folder"))

        // Then
        do {
            let loadedFiles: [MockPackage] = try PackagableDisk.packages(in: .documents, path: "some_folder")
            
            guard loadedFiles.count == 2 else {
                XCTAssert(false)
                return
            }
            
            XCTAssert(loadedFiles[0] == testFiles[0])
            XCTAssert(loadedFiles[1] == testFiles[1])
        } catch {
            XCTAssert(false)
        }
    }
    
    func testGivenDifferentPackagableFiles_WhenSaveFile_ThenPackagableDiskReturnsFilesOfCorrectType() {
        // Given
        let testFiles = [
            MockPackage(id: "ABC"),
            MockPackage(id: "123")
        ]
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder/sub_folder", in: .documents))
        XCTAssertNoThrow(try PackagableDisk.store(testFiles[0], to: .documents, as: "example_2.other_package", path: "some_folder"))
        XCTAssertNoThrow(try PackagableDisk.store(testFiles[1], to: .documents, as: "example_1.package", path: "some_folder/sub_folder"))
        
        // Then
        do {
            let loadedFiles: [MockPackage] = try PackagableDisk.packages(in: .documents, path: "some_folder")
            
            guard loadedFiles.count == 1 else {
                XCTAssert(false)
                return
            }
            
            XCTAssert(loadedFiles[0] == testFiles[1])
        } catch {
            XCTAssert(false)
        }
    }
    
    func testGivenDifferentStoredFiles_WhenQueingDirectories_ThenFilesAreReturnedCorrectly() {
        // Given
        let testFiles = [
            MockPackage(id: "ABC"),
            MockPackage(id: "123")
        ]
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder/sub_folder", in: .documents))
        XCTAssertNoThrow(try PackagableDisk.store(testFiles[0], to: .documents, as: "other_package", path: "some_folder"))
        XCTAssertNoThrow(try PackagableDisk.store(testFiles[1], to: .documents, as: "example_1.package", path: "some_folder/sub_folder"))
        
        // Then
        do {
            let url = Disk.Directory.documents.makeUrl(path: "some_folder")
            let loadedDirectory = try PackagableDisk.directory(at: url)
            let packageDirectory = try loadedDirectory.directory("sub_folder")
            let otherDirectory = try loadedDirectory.directory("other_package")
            let codableListDirectory = try otherDirectory.directory("codable_list")
            let diskCodableListDirectory = try otherDirectory.directory("disk_codable_list")
            let codable: MockCodable = try codableListDirectory.file("file_2")
            let diskCodable: MockDiskCodable = try diskCodableListDirectory.file("file_2")
            let package: MockPackage = try packageDirectory.package("example_1.package")
            
            XCTAssertNotNil(package)
            XCTAssertNotNil(codable)
            XCTAssertNotNil(diskCodable)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testGivenCodableFile_WhenSaveFile_ThenFileExistsReturnsTrue() {
        // Given
        let filename = "example.directory"
        let testFile = MockPackage(id: "ABC")
        
        // When
        XCTAssertNoThrow(try PackagableDisk.store(testFile, to: .documents, as: filename))
        
        // Then
        XCTAssertTrue(Disk.fileExists(in: .documents, withFileName: filename))
        
    }
    
    func testGivenCodableFile_WhenSaveFile_CanOverwriteFile() {
        // Given
        let filename = "example.directory"
        var testFile = MockPackage(id: "ABC")
        
        // When
        XCTAssertNoThrow(try Disk.create(path: "some_folder", in: .documents))
        XCTAssertNoThrow(try PackagableDisk.store(testFile, to: .documents, as: filename, path: "some_folder"))
        testFile.codable.id = UUID().uuidString
        
        // Then
        XCTAssertNoThrow(try PackagableDisk.store(testFile, to: .documents, as: filename, path: "some_folder"))
    }
}
