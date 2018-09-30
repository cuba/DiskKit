//
//  MockCodable.swift
//  DiskKitTests
//
//  Created by Jacob Sikorski on 2018-09-10.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation
@testable import DiskKit

struct MockCodable: Codable {
    var id = UUID().uuidString
    
    init(id: String) {
        self.id = id
    }
}

extension MockCodable: Equatable {
    
    public static func == (lhs: MockCodable, rhs: MockCodable) -> Bool {
        return lhs.id == rhs.id
    }
}

struct MockDiskCodable: DiskCodable {
    var id = UUID().uuidString
    
    init(id: String) {
        self.id = id
    }
    
    init(_ data: Data) throws {
        id = String(data: data, encoding: .utf8)!
    }
    
    func encode() throws -> Data {
        return id.data(using: .utf8)!
    }
}

extension MockDiskCodable: Equatable {
    
    public static func == (lhs: MockDiskCodable, rhs: MockDiskCodable) -> Bool {
        return lhs.id == rhs.id
    }
}

struct MockPackage: Package {
    static let typeIdentifier = "com.jacobsikorski.diskkit.example.package"
    
    var codable: MockCodable
    var diskCodable: MockDiskCodable
    var codableArray: [MockCodable]
    var diskCodableArray: [MockDiskCodable]
    
    init(id: String) {
        self.codable = MockCodable(id: "CODABLE_\(id)")
        self.diskCodable = MockDiskCodable(id: "DISK_CODABLE_\(id)")
        
        self.codableArray = [
            MockCodable(id: "CODABLE_\(id)_1"),
            MockCodable(id: "CODABLE_\(id)_2"),
            MockCodable(id: "CODABLE_\(id)_3")
        ]
        
        self.diskCodableArray = [
            MockDiskCodable(id: "DISK_CODABLE_\(id)_1"),
            MockDiskCodable(id: "DISK_CODABLE_\(id)_2"),
            MockDiskCodable(id: "DISK_CODABLE_\(id)_3")
        ]
    }
    
    init(directory: Directory) throws {
        self.codable = try directory.file("codable.json")
        self.diskCodable = try directory.file("disk_codable.json")
        self.codableArray = try directory.fileArray("codable_list")
        self.diskCodableArray = try directory.fileArray("disk_codable_list")
    }
    
    func fill(directory: Directory) throws {
        try directory.add(codable, name: "codable.json")
        try directory.add(diskCodable, name: "disk_codable.json")
        try directory.add(codableArray, name: "codable_list")
        try directory.add(diskCodableArray, name: "disk_codable_list")
    }
}

extension MockPackage: Equatable {
    
    public static func == (lhs: MockPackage, rhs: MockPackage) -> Bool {
        return lhs.codable == rhs.codable && lhs.diskCodable == rhs.diskCodable
    }
}

class MockMigration: Migration {
    var uniqueName: String
    var numberOfTimesRan = 0
    var errors: [Error] = []
    let directory: URL
    
    func migrate() {
        let packages: [MockPackage] = [
            MockPackage(id: "\(uniqueName)_1"),
            MockPackage(id: "\(uniqueName)_2"),
            MockPackage(id: "\(uniqueName)_3"),
            MockPackage(id: "\(uniqueName)_4"),
            MockPackage(id: "\(uniqueName)_5"),
            MockPackage(id: "\(uniqueName)_6")
        ]
        
        numberOfTimesRan += 1
        
        for package in packages {
            let filename = "\(Date().timeIntervalSince1970)"
            let url = directory.appendingPathComponent(filename)
            
            do {
                try PackagableDisk.store(package, to: url)
            } catch let error {
                errors.append(error)
            }
        }
    }
    
    init(uniqueName: String, directory: URL) {
        self.uniqueName = uniqueName
        self.directory = directory
    }
}
