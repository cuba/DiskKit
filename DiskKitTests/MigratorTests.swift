//
//  MigratorTests.swift
//  DiskKitTests
//
//  Created by Jacob Sikorski on 2018-09-22.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import XCTest
@testable import DiskKit

class MigratorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Migrator.shared.reset()
    }
    
    override func tearDown() {
        Migrator.shared.reset()
        super.tearDown()
    }
    
    func testGivenMigrations_WhenMigrated_OnlyRunsOnce() {
        // Given
        let migrations = [
            MockMigration(uniqueName: "MockMigration1"),
            MockMigration(uniqueName: "MockMigration2")
        ]
        
        // When
        Migrator.shared.migrate(migrations)
        Migrator.shared.migrate(migrations)
        
        // Then
        XCTAssert(migrations[0].numberOfTimesRan == 1)
        XCTAssert(migrations[1].numberOfTimesRan == 1)
    }
}
