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
    var subPackage: AnotherMockPackage
    
    init(codable: MockCodable, diskCodable: MockDiskCodable, subPackage: AnotherMockPackage) {
        self.codable = codable
        self.diskCodable = diskCodable
        self.subPackage = subPackage
    }
    
    init(map: PackageMap) throws {
        self.codable = try map.file("codable.json")
        self.diskCodable = try map.file("disk_codable.json")
        self.subPackage = try map.package("sub_package")
    }
    
    func mapping(map: PackageMap) throws {
        try map.add(codable, name: "codable.json")
        try map.add(diskCodable, name: "disk_codable.json")
        try map.add(subPackage, name: "sub_package")
    }
}

struct AnotherMockPackage: Package {
    var codable: MockCodable
    var diskCodable: MockDiskCodable
    
    init(codable: MockCodable, diskCodable: MockDiskCodable) {
        self.codable = codable
        self.diskCodable = diskCodable
    }
    
    init(map: PackageMap) throws {
        self.codable = try map.file("codable.json")
        self.diskCodable = try map.file("disk_codable.json")
    }
    
    func mapping(map: PackageMap) throws {
        try map.add(codable, name: "codable.json")
        try map.add(diskCodable, name: "disk_codable.json")
    }
}

extension MockPackage: Equatable {
    
    public static func == (lhs: MockPackage, rhs: MockPackage) -> Bool {
        return lhs.codable == rhs.codable && lhs.diskCodable == rhs.diskCodable
    }
}
