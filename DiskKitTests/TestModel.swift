//
//  TestCodable.swift
//  DiskKitTests
//
//  Created by Jacob Sikorski on 2018-09-10.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation
@testable import DiskKit

struct TestCodable: Codable {
    var id = UUID().uuidString
    
    init(id: String) {
        self.id = id
    }
}

extension TestCodable: Equatable {
    
    public static func == (lhs: TestCodable, rhs: TestCodable) -> Bool {
        return lhs.id == rhs.id
    }
}

struct TestDiskCodable: DiskCodable {
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

extension TestDiskCodable: Equatable {
    
    public static func == (lhs: TestDiskCodable, rhs: TestDiskCodable) -> Bool {
        return lhs.id == rhs.id
    }
}

struct TestPackage: Package {
    var codable: TestCodable
    var diskCodable: TestDiskCodable
    
    init(codable: TestCodable, diskCodable: TestDiskCodable) {
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

extension TestPackage: Equatable {
    
    public static func == (lhs: TestPackage, rhs: TestPackage) -> Bool {
        return lhs.codable == rhs.codable && lhs.diskCodable == rhs.diskCodable
    }
}
