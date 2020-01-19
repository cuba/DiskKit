//
//  Package.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-16.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public protocol Package {
    static var typeIdentifier: String { get }
    init(directory: Directory) throws
    func fill(directory: Directory) throws
}

public extension Package {
    
    func makeFileWrapper(saveUrl: URL) throws -> FileWrapper {
        let directory = Directory(name: saveUrl.lastPathComponent, saveUrl: saveUrl)
        try fill(directory: directory)
        return try directory.makeFileWrapper()
    }
}
