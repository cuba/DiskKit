//
//  Migrator.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-22.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public class Migrator {
    public static let shared = Migrator()
    private let migrationsKey = "com.pineapplepush.DiskKit.Migrations"
    
    public init() {}
    
    public func migrate(_ migrations: [Migration]) {
        let userDefaults = UserDefaults.standard
        var keys: [String] = (userDefaults.array(forKey: "com.pineapplepush.DiskKit.Migrations") as? [String]) ?? []
        
        for migration in migrations {
            let migrationName = migration.uniqueName
            guard !keys.contains(migrationName) else { continue }
            migration.migrate()
            keys.append(migrationName)
            userDefaults.set(keys, forKey: migrationsKey)
        }
    }
    
    public func reset() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: migrationsKey)
    }
}
