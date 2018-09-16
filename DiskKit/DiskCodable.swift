//
//  DiskCodable.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-16.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public protocol DiskEncodable {
    func encode() throws -> Data
}

public protocol DiskDecodable {
    init(_ data: Data) throws
}

public protocol DiskCodable: DiskEncodable, DiskDecodable {
}
