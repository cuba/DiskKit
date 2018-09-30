//
//  Packagable.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-16.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public protocol Packagable {
    static var typeIdentifier: String { get }
    init(package: Package) throws
    func fill(package: Package) throws
}

public extension Packagable {
    
    public func makeFileWrapper(saveUrl: URL) throws -> FileWrapper {
        let package = Package(filename: saveUrl.lastPathComponent, savedUrl: saveUrl, typeIdentifier: type(of: self).typeIdentifier)
        try fill(package: package)
        return try package.makeFileWrapper()
    }
}
