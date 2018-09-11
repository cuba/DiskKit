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
        
    }
    
    func testGivenCodableFile_WhenSaveFile_ThenDiskDataArrayReturnsAllFiles() {
        
    }
    
    func testGivenCodableFile_WhenSaveFile_ThenFileExistsReturnsTrue() {
        
    }
    
}
