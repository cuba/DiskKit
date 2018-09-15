//
//  Package.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-15.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public class Package {
    private(set) public var files: [DiskData] = []
    private(set) public var directories: [String: Package] = [:]
    
    init() {}
    
    convenience init(_ fileWrapper: FileWrapper) throws {
        self.init()
        
        for (name, subFileWrapper) in fileWrapper.fileWrappers ?? [:] {
            if subFileWrapper.isDirectory {
                directories[name] = try Package(subFileWrapper)
            } else {
                guard let data = subFileWrapper.regularFileContents else { continue }
                add(DiskData(data: data, name: name))
            }
        }
    }
    
    public func add<T: Encodable>(_ file: T, name: String) throws {
        let diskData = try DiskData(file: file, name: name)
        add(diskData)
    }
    
    public func add<T: DiskEncodable>(_ file: T, name: String) throws {
        let diskData = try DiskData(file: file, name: name)
        add(diskData)
    }
    
    public func add(_ file: DiskData) {
        if let index = files.index(of: file) {
            files[index] = file
        } else {
            files.append(file)
        }
    }
    
    public func add<T: DiskEncodable>(_ fileArray: [T], name: String) throws {
        let package = Package()
        
        for (index, file) in fileArray.enumerated() {
            try package.add(file, name: "file_\(index)")
        }
        
        directories[name] = package
    }
    
    public func add<T: Encodable>(_ fileArray: [T], name: String) throws {
        let package = Package()
        
        for (index, file) in fileArray.enumerated() {
            try package.add(file, name: "file_\(index)")
        }
        
        directories[name] = package
    }
    
    public func add(_ fileArray: [DiskData], name: String) throws {
        let package = Package()
        
        for (_, file) in fileArray.enumerated() {
            package.add(file)
        }
        
        directories[name] = package
    }
    
    public func add<T: Packagable>(_ packagable: T, name: String) throws {
        let package = Package()
        try packagable.mapping(package: package)
        directories[name] = package
    }
    
    public func add<T: Packagable>(_ packagableArray: [T], name: String) throws {
        let package = Package()
        
        for (index, packagable) in packagableArray.enumerated() {
            try package.add(packagable, name: "package_\(index)")
        }
        
        directories[name] = package
    }
    
    public func file<T: Decodable>(_ name: String) throws -> T? {
        guard let diskData = files.first(where: { $0.fileName == name }) else { return nil }
        return try diskData.decode()
    }
    
    public func file<T: Decodable>(_ name: String) throws -> T {
        guard let diskData = files.first(where: { $0.fileName == name }) else {
            throw PackageReadError.fileNotFound
        }
        
        return try diskData.decode()
    }
    
    public func fileArray<T: Decodable>() throws -> [T] {
        var files: [T] = []
        
        for diskData in self.files {
            let file: T = try diskData.decode()
            files.append(file)
        }
        
        return files
    }
    
    public func fileArray<T: Decodable>(_ directoryName: String) throws -> [T] {
        guard let package = directories[directoryName] else {
            throw PackageReadError.directoryNotFound
        }
        
        return try package.fileArray()
    }
    
    public func file<T: DiskDecodable>(_ name: String) throws -> T? {
        guard let diskData = files.first(where: { $0.fileName == name }) else { return nil }
        return try diskData.decode()
    }
    
    public func file<T: DiskDecodable>(_ name: String) throws -> T {
        guard let diskData = files.first(where: { $0.fileName == name }) else {
            throw PackageReadError.fileNotFound
        }
        
        return try diskData.decode()
    }
    
    public func fileArray<T: DiskDecodable>() throws -> [T] {
        var files: [T] = []
        
        for diskData in self.files {
            let file: T = try diskData.decode()
            files.append(file)
        }
        
        return files
    }
    
    public func fileArray<T: DiskDecodable>(_ directoryName: String) throws -> [T] {
        guard let package = directories[directoryName] else {
            throw PackageReadError.directoryNotFound
        }
        
        return try package.fileArray()
    }
    
    public func file<T: Packagable>(_ name: String) throws -> T? {
        guard let package = directories[name] else { return nil }
        return try T(package: package)
    }
    
    public func file<T: Packagable>(_ name: String) throws -> T {
        guard let package = directories[name] else {
            throw PackageReadError.directoryNotFound
        }
        
        return try T(package: package)
    }
    
    public func fileArray<T: Packagable>(_ name: String) throws -> [T] {
        guard let package = directories[name] else {
            throw PackageReadError.directoryNotFound
        }
        
        return try package.fileArray()
    }
    
    public func fileArray<T: Packagable>() throws -> [T] {
        var files: [T] = []
        
        for (_, package) in directories {
            let file = try T(package: package)
            files.append(file)
        }
        
        return files
    }
    
    func makeFileWrapper() throws -> FileWrapper {
        var fileWrappers: [String: FileWrapper] = [:]
        
        for file in files {
            fileWrappers[file.fileName] = file.makeFileWrapper()
        }
        
        for (directoryName, package) in directories {
            fileWrappers[directoryName] = try package.makeFileWrapper()
        }
        
        return FileWrapper(directoryWithFileWrappers: fileWrappers)
    }
}