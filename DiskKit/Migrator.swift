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
    private let migrationsStorageKey = "com.pineapplepush.DiskKit.Migrations"
    private var migrations: [String]
    
    public init() {
        let userDefaults = UserDefaults.standard
        self.migrations = userDefaults.array(forKey: migrationsStorageKey) as? [String] ?? []
    }
    
    public func migrate(_ migrations: [Migration]) {
        for migration in migrations {
            guard !isMigrated(migration) else { continue }
            migration.migrate()
            markAsMigrated(for: migration)
        }
    }
    
    public func reset() {
        migrations = []
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: migrationsStorageKey)
    }
    
    public func reset(_ migration: Migration) {
        resetMigration(withName: migration.uniqueName)
    }
    
    public func resetMigration(withName name: String) {
        while let index = migrations.index(of: name) {
            migrations.remove(at: index)
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(migrations, forKey: migrationsStorageKey)
    }
    
    public func isMigrated(_ migration: Migration) -> Bool {
        return migrations.contains(migration.uniqueName)
    }
    
    public func markAsMigrated(for migration: Migration) {
        guard !isMigrated(migration) else { return }
        migrations.append(migration.uniqueName)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(migrations, forKey: migrationsStorageKey)
    }
}
