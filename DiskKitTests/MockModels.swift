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
    var codable: MockCodable
    var diskCodable: MockDiskCodable
    var subPackage: MockSubPackage
    var packageArray: [MockSubPackage]
    var codableArray: [MockCodable]
    var diskCodableArray: [MockDiskCodable]
    
    init(id: String) {
        self.codable = MockCodable(id: "CODABLE_\(id)")
        self.diskCodable = MockDiskCodable(id: "DISK_CODABLE_\(id)")
        self.subPackage = MockSubPackage(id: id)
        
        self.packageArray = [
            MockSubPackage(id: "id_\(1)"),
            MockSubPackage(id: "id_\(2)"),
            MockSubPackage(id: "id_\(3)")
        ]
        
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
    
    init(map: PackageMap) throws {
        self.codable = try map.file("codable.json")
        self.diskCodable = try map.file("disk_codable.json")
        self.subPackage = try map.package("sub_package")
        self.codableArray = try map.fileArray("codable_list")
        self.diskCodableArray = try map.fileArray("disk_codable_list")
        self.packageArray = try map.packageArray("sub_package_list")
    }
    
    func mapping(map: PackageMap) throws {
        try map.add(codable, name: "codable.json")
        try map.add(diskCodable, name: "disk_codable.json")
        try map.add(subPackage, name: "sub_package")
        try map.add(codableArray, name: "codable_list")
        try map.add(diskCodableArray, name: "disk_codable_list")
        try map.add(packageArray, name: "sub_package_list")
    }
}

struct MockSubPackage: Package {
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
    
    init(map: PackageMap) throws {
        self.codable = try map.file("codable.json")
        self.diskCodable = try map.file("disk_codable.json")
        self.codableArray = try map.fileArray("codable_list")
        self.diskCodableArray = try map.fileArray("disk_codable_list")
    }
    
    func mapping(map: PackageMap) throws {
        try map.add(codable, name: "codable.json")
        try map.add(diskCodable, name: "disk_codable.json")
        try map.add(codableArray, name: "codable_list")
        try map.add(diskCodableArray, name: "disk_codable_list")
    }
}

extension MockPackage: Equatable {
    
    public static func == (lhs: MockPackage, rhs: MockPackage) -> Bool {
        return lhs.codable == rhs.codable && lhs.diskCodable == rhs.diskCodable
    }
}
