//
//  Package.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-15.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation
import UIKit

public enum PackageEncodingError: Error {
    case unableToEncodeFile(cause: Error?)
}

public enum PackageDecodingError: Error {
    case fileNotFound
    case directoryNotFound
    case notFolder
    case unableToDecodeFile(cause: Error?)
}

public class Package {
    private(set) public var filename: String
    private(set) public var savedUrl: URL
    private(set) public var files: [DiskData] = []
    private(set) public var directories: [String: Package] = [:]
    
    init(filename: String, savedUrl: URL) {
        self.filename = filename
        self.savedUrl = savedUrl
    }
    
    public convenience init(_ fileWrapper: FileWrapper, savedUrl: URL) throws {
        self.init(filename: fileWrapper.filename!, savedUrl: savedUrl)
        
        for (name, subFileWrapper) in fileWrapper.fileWrappers ?? [:] {
            if subFileWrapper.isDirectory {
                directories[name] = try Package(subFileWrapper, savedUrl: savedUrl.appendingPathComponent(name))
            } else {
                guard let data = subFileWrapper.regularFileContents else { continue }
                add(DiskData(data: data, name: name))
            }
        }
    }
    
    // MARK: - Add
    
    public func add(data: Data, name: String) {
        let diskData = DiskData(data: data, name: name)
        add(diskData)
    }
    
    public func add(_ file: DiskData) {
        if let index = files.index(of: file) {
            files[index] = file
        } else {
            files.append(file)
        }
    }
    
    public func add(text: String?, name: String, encoding: String.Encoding) throws {
        guard let text = text else { return }
        
        do {
            let diskData = try DiskData(text: text, name: name, encoding: encoding)
            add(diskData)
        } catch let error {
            throw PackageEncodingError.unableToEncodeFile(cause: error)
        }
    }
    
    public func add(_ image: UIImage?, name: String, type: ImageFileType) throws {
        guard let image = image else { return }
        
        do {
            let diskData = try DiskData(image: image, name: name, type: type)
            add(diskData)
        } catch let error {
            throw PackageEncodingError.unableToEncodeFile(cause: error)
        }
    }
    
    public func add<T: Encodable>(_ file: T?, name: String) throws {
        guard let file = file else { return }
        
        do {
            let diskData = try DiskData(file: file, name: name)
            add(diskData)
        } catch let error {
            throw PackageEncodingError.unableToEncodeFile(cause: error)
        }
    }
    
    public func add<T: DiskEncodable>(_ file: T?, name: String) throws {
        guard let file = file else { return }
        
        do {
            let diskData = try DiskData(file: file, name: name)
            add(diskData)
        } catch let error {
            throw PackageEncodingError.unableToEncodeFile(cause: error)
        }
    }
    
    public func add<T: DiskEncodable>(_ fileArray: [T], name: String) throws {
        let package = Package(filename: name, savedUrl: savedUrl.appendingPathComponent(name))
        
        for (index, file) in fileArray.enumerated() {
            try package.add(file, name: "file_\(index)")
        }
        
        directories[name] = package
    }
    
    public func add<T: Encodable>(_ fileArray: [T], name: String) throws {
        let package = Package(filename: name, savedUrl: savedUrl.appendingPathComponent(name))
        
        for (index, file) in fileArray.enumerated() {
            try package.add(file, name: "file_\(index)")
        }
        
        directories[name] = package
    }
    
    public func add(_ diskDataArray: [DiskData], name: String) throws {
        let package = Package(filename: name, savedUrl: savedUrl.appendingPathComponent(name))
        
        for (_, file) in diskDataArray.enumerated() {
            package.add(file)
        }
        
        directories[name] = package
    }
    
    public func add<T: Packagable>(_ packagable: T?, name: String) throws {
        guard let packagable = packagable else { return }
        
        let package = Package(filename: name, savedUrl: savedUrl.appendingPathComponent(name))
        try packagable.fill(package: package)
        directories[name] = package
    }
    
    public func add<T: Packagable>(_ packagableArray: [T], name: String) throws {
        let package = Package(filename: name, savedUrl: savedUrl.appendingPathComponent(name))
        
        for (index, packagable) in packagableArray.enumerated() {
            do {
                try package.add(packagable, name: "package_\(index)")
            } catch let error {
                throw PackageEncodingError.unableToEncodeFile(cause: error)
            }
        }
        
        directories[name] = package
    }
    
    // MARK: - Get Data
    
    public func data(_ name: String) throws -> Data {
        guard let diskData = files.first(where: { $0.filename == name }) else {
            throw PackageDecodingError.fileNotFound
        }
        
        return diskData.data
    }
    
    // MARK: - Get DiskData
    
    public func diskData(_ name: String) throws -> DiskData {
        guard let diskData = files.first(where: { $0.filename == name }) else {
            throw PackageDecodingError.fileNotFound
        }
        
        return diskData
    }
    
    public func diskData(_ name: String) -> DiskData? {
        return files.first(where: { $0.filename == name })
    }
    
    // MARK: - Get Decodable
    
    public func file<T: Decodable>(_ name: String) throws -> T? {
        guard let diskData = files.first(where: { $0.filename == name }) else { return nil }
        return try diskData.decode()
    }
    
    public func file<T: Decodable>(_ name: String) throws -> T {
        guard let diskData = files.first(where: { $0.filename == name }) else {
            throw PackageDecodingError.fileNotFound
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
            throw PackageDecodingError.directoryNotFound
        }
        
        return try package.fileArray()
    }
    
    // MARK: - Get DiskDecodable
    
    public func file<T: DiskDecodable>(_ name: String) throws -> T? {
        guard let diskData = files.first(where: { $0.filename == name }) else { return nil }
        
        do {
            return try diskData.decode()
        } catch let error {
            throw PackageDecodingError.unableToDecodeFile(cause: error)
        }
    }
    
    public func file<T: DiskDecodable>(_ name: String) throws -> T {
        guard let diskData = files.first(where: { $0.filename == name }) else {
            throw PackageDecodingError.fileNotFound
        }
        
        return try diskData.decode()
    }
    
    public func fileArray<T: DiskDecodable>() throws -> [T] {
        var files: [T] = []
        
        for diskData in self.files {
            do {
                let file: T = try diskData.decode()
                files.append(file)
            } catch let error {
                throw PackageDecodingError.unableToDecodeFile(cause: error)
            }
        }
        
        return files
    }
    
    public func fileArray<T: DiskDecodable>(_ directoryName: String) throws -> [T] {
        guard let package = directories[directoryName] else {
            throw PackageDecodingError.directoryNotFound
        }
        
        return try package.fileArray()
    }
    
    // MARK: - Get Image
    
    public func image(_ name: String) throws -> UIImage {
        let diskData: DiskData = try self.diskData(name)
        
        guard let image = diskData.image() else {
            throw PackageDecodingError.unableToDecodeFile(cause: nil)
        }
        
        return image
    }
    
    public func image(_ name: String) throws -> UIImage? {
        guard let diskData = files.first(where: { $0.filename == name }) else { return nil }
        
        guard let image = diskData.image() else {
            throw PackageDecodingError.unableToDecodeFile(cause: nil)
        }
        
        return image
    }
    
    // MARK: - Get Text
    
    public func text(_ name: String, encoding: String.Encoding) throws -> String {
        let diskData: DiskData = try self.diskData(name)
        
        guard let text = diskData.text(encoding: encoding) else {
            throw PackageDecodingError.unableToDecodeFile(cause: nil)
        }
        
        return text
    }
    
    public func text(_ name: String, encoding: String.Encoding) throws -> String? {
        guard let diskData = files.first(where: { $0.filename == name }) else { return nil }
        
        guard let text = diskData.text(encoding: encoding) else {
            throw PackageDecodingError.unableToDecodeFile(cause: nil)
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
            throw PackageDecodingError.directoryNotFound
        }
        
        return try T(package: package)
    }
    
    public func fileArray<T: Packagable>(_ name: String) throws -> [T] {
        guard let package = directories[name] else {
            throw PackageDecodingError.directoryNotFound
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
            fileWrappers[file.filename] = file.makeFileWrapper()
        }
        
        for (directoryName, package) in directories {
            fileWrappers[directoryName] = try package.makeFileWrapper()
        }
        
        return FileWrapper(directoryWithFileWrappers: fileWrappers)
    }
}
