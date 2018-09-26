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
        let directory = Disk.Directory.documents.baseUrl
        let migrations = [
            MockMigration(uniqueName: "MockMigration1", directory: directory),
            MockMigration(uniqueName: "MockMigration2", directory: directory)
        ]
        
        // When
        Migrator.shared.migrate(migrations)
        Migrator.shared.migrate(migrations)
        
        // Then
        XCTAssert(migrations[0].numberOfTimesRan == 1)
        XCTAssert(migrations[1].numberOfTimesRan == 1)
        XCTAssert(migrations[0].errors.count == 0)
        XCTAssert(migrations[1].errors.count == 0)
    }
    
    func testGivenMigration_WhenMigrated_ResetMigrationsWorks() {
        // Given
        let directory = Disk.Directory.documents.baseUrl
        let migration = MockMigration(uniqueName: "MockMigration", directory: directory)
        
        // When
        Migrator.shared.migrate([migration])
        Migrator.shared.reset(migration)
        Migrator.shared.migrate([migration])
        
        // Then
        XCTAssert(migration.numberOfTimesRan == 2)
    }
}
