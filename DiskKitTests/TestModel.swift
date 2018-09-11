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
