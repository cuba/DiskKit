//
//  Package.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-15.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation
import UIKit

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
    
    // MARK: - Add
    
    public func add(text: String, name: String) throws {
        let diskData = try DiskData(text: text, name: name)
        add(diskData)
    }
    
    public func add(_ image: UIImage, name: String, type: ImageFileType) throws {
        let diskData = try DiskData(image: image, name: name, type: type)
        add(diskData)
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
        try packagable.fill(package: package)
        directories[name] = package
    }
    
    public func add<T: Packagable>(_ packagableArray: [T], name: String) throws {
        let package = Package()
        
        for (index, packagable) in packagableArray.enumerated() {
            try package.add(packagable, name: "package_\(index)")
        }
        
        directories[name] = package
    }
    
    // MARK: - Get DiskData
    
    public func diskData(_ name: String) throws -> DiskData {
        guard let diskData = files.first(where: { $0.fileName == name }) else {
            throw PackageReadError.fileNotFound
        }
        
        return diskData
    }
    
    public func diskData(_ name: String) -> DiskData? {
        return files.first(where: { $0.fileName == name })
    }
    
    // MARK: - Get Decodable
    
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
    
    // MARK: - Get DiskDecodable
    
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
    
    // MARK: - Get Image
    
    public func image(_ name: String) throws -> UIImage {
        let diskData: DiskData = try self.diskData(name)
        
        guard let image = diskData.image() else {
            throw PackageReadError.unableToReadFile
        }
        
        return image
    }
    
    public func image(_ name: String) throws -> UIImage? {
        guard let diskData = files.first(where: { $0.fileName == name }) else { return nil }
        
        guard let image = diskData.image() else {
            throw PackageReadError.unableToReadFile
        }
        
        return image
    }
    
    // MARK: - Get Text
    
    public func text(_ name: String, encoding: String.Encoding) throws -> String {
        let diskData: DiskData = try self.diskData(name)
        
        guard let text = diskData.text(encoding: encoding) else {
            throw PackageReadError.unableToReadFile
        }
        
        return text
    }
    
    public func text(_ name: String, encoding: String.Encoding) throws -> String? {
        guard let diskData = files.first(where: { $0.fileName == name }) else { return nil }
        
        guard let text = diskData.text(encoding: encoding) else {
            throw PackageReadError.unableToReadFile
        }
        
        return text
    }
    
    // MARK: - Get Packagable
    
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
    
    public func makeFileWrapper() throws -> FileWrapper {
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
