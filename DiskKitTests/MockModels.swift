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

struct MockPackage: Packagable {
    var codable: MockCodable
    var diskCodable: MockDiskCodable
    var subPackage: MockSubPackage
    var packagableArray: [MockSubPackage]
    var codableArray: [MockCodable]
    var diskCodableArray: [MockDiskCodable]
    
    init(id: String) {
        self.codable = MockCodable(id: "CODABLE_\(id)")
        self.diskCodable = MockDiskCodable(id: "DISK_CODABLE_\(id)")
        self.subPackage = MockSubPackage(id: id)
        
        self.packagableArray = [
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
    
    init(package: Package) throws {
        self.codable = try package.file("codable.json")
        self.diskCodable = try package.file("disk_codable.json")
        self.subPackage = try package.file("sub_package")
        self.codableArray = try package.fileArray("codable_list")
        self.diskCodableArray = try package.fileArray("disk_codable_list")
        self.packagableArray = try package.fileArray("sub_package_list")
    }
    
    func mapping(package: Package) throws {
        try package.add(codable, name: "codable.json")
        try package.add(diskCodable, name: "disk_codable.json")
        try package.add(subPackage, name: "sub_package")
        try package.add(codableArray, name: "codable_list")
        try package.add(diskCodableArray, name: "disk_codable_list")
        try package.add(packagableArray, name: "sub_package_list")
    }
}

struct MockSubPackage: Packagable {
    var codable: MockCodable
    var diskCodable: MockDiskCodable
    var codableArray: [MockCodable]
    var diskCodableArray: [MockDiskCodable]
    var image: UIImage
    var image2: UIImage
    var exampleText: String
    
    init(id: String) {
        self.codable = MockCodable(id: "CODABLE_\(id)")
        self.diskCodable = MockDiskCodable(id: "DISK_CODABLE_\(id)")
        let bundle = Bundle(for: EncodableDiskTests.self)
        self.image = UIImage(named: "example", in: bundle, compatibleWith: nil)!
        self.image2 = UIImage(named: "example", in: bundle, compatibleWith: nil)!
        self.exampleText = "This is some example text"
        
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
    
    init(package: Package) throws {
        self.codable = try package.file("codable.json")
        self.diskCodable = try package.file("disk_codable.json")
        self.codableArray = try package.fileArray("codable_list")
        self.diskCodableArray = try package.fileArray("disk_codable_list")
        self.image = try package.image("image.jpg")
        self.image2 = try package.image("image.png")
        self.exampleText = try package.text("example.txt")
    }
    
    func mapping(package: Package) throws {
        try package.add(codable, name: "codable.json")
        try package.add(diskCodable, name: "disk_codable.json")
        try package.add(codableArray, name: "codable_list")
        try package.add(diskCodableArray, name: "disk_codable_list")
        try package.add(image, name: "image.jpg", type: .jpg(compressionQuality: 0.5))
        try package.add(image2, name: "image.png", type: .png)
        try package.add(text: exampleText, name: "example.txt")
    }
}

extension MockPackage: Equatable {
    
    public static func == (lhs: MockPackage, rhs: MockPackage) -> Bool {
        return lhs.codable == rhs.codable && lhs.diskCodable == rhs.diskCodable
    }
}
