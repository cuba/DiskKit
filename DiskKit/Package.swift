//
//  Directory.swift
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

public class Directory {
    public let name: String
    public let saveUrl: URL
    public let typeIdentifier: String?
    private(set) public var files: [File] = []
    private(set) public var directories: [Directory] = []
    
    init(name: String, saveUrl: URL, typeIdentifier: String?) {
        self.name = name
        self.saveUrl = saveUrl
        self.typeIdentifier = typeIdentifier
    }
    
    convenience init(_ fileWrapper: FileWrapper, saveUrl: URL, typeIdentifier: String?) {
        self.init(name: fileWrapper.filename!, saveUrl: saveUrl, typeIdentifier: typeIdentifier)
        
        for (name, subFileWrapper) in fileWrapper.fileWrappers ?? [:] {
            if subFileWrapper.isDirectory {
                let directory = Directory(subFileWrapper, saveUrl: saveUrl.appendingPathComponent(name), typeIdentifier: nil)
                directories.append(directory)
            } else {
                guard let data = subFileWrapper.regularFileContents else { continue }
                add(File(data: data, name: name))
            }
        }
    }
    
    // MARK: - Add
    
    public func add(data: Data, name: String) {
        let file = File(data: data, name: name)
        add(file)
    }
    
    public func add(_ file: File) {
        if let index = files.index(of: file) {
            files[index] = file
        } else {
            files.append(file)
        }
    }
    
    public func add(text: String?, name: String, encoding: String.Encoding) throws {
        guard let text = text else { return }
        
        do {
            let file = try File(text: text, name: name, encoding: encoding)
            add(file)
        } catch let error {
            throw PackageEncodingError.unableToEncodeFile(cause: error)
        }
    }
    
    public func add(_ image: UIImage?, name: String, type: ImageFileType) throws {
        guard let image = image else { return }
        
        do {
            let file = try File(image: image, name: name, type: type)
            add(file)
        } catch let error {
            throw PackageEncodingError.unableToEncodeFile(cause: error)
        }
    }
    
    public func add<T: Encodable>(_ file: T?, name: String) throws {
        guard let file = file else { return }
        
        do {
            let file = try File(file: file, name: name)
            add(file)
        } catch let error {
            throw PackageEncodingError.unableToEncodeFile(cause: error)
        }
    }
    
    public func add<T: DiskEncodable>(_ file: T?, name: String) throws {
        guard let file = file else { return }
        
        do {
            let file = try File(file: file, name: name)
            add(file)
        } catch let error {
            throw PackageEncodingError.unableToEncodeFile(cause: error)
        }
    }
    
    public func add<T: DiskEncodable>(_ fileArray: [T], name: String) throws {
        let directory = Directory(name: name, saveUrl: saveUrl.appendingPathComponent(name), typeIdentifier: nil)
        
        for (index, file) in fileArray.enumerated() {
            try directory.add(file, name: "file_\(index)")
        }
        
        directories.append(directory)
    }
    
    public func add<T: Encodable>(_ fileArray: [T], name: String) throws {
        let directory = Directory(name: name, saveUrl: saveUrl.appendingPathComponent(name), typeIdentifier: nil)
        
        for (index, file) in fileArray.enumerated() {
            try directory.add(file, name: "file_\(index)")
        }
        
        directories.append(directory)
    }
    
    public func add(_ filesArray: [File], name: String) throws {
        let directory = Directory(name: name, saveUrl: saveUrl.appendingPathComponent(name), typeIdentifier: nil)
        
        for (_, file) in filesArray.enumerated() {
            directory.add(file)
        }
        
        directories.append(directory)
    }
    
    public func add(_ directory: Directory, name: String) {
        directories.append(directory)
    }
    
    // MARK: - Get Data
    
    public func data(_ name: String) throws -> Data {
        guard let file = files.first(where: { $0.filename == name }) else {
            throw PackageDecodingError.fileNotFound
        }
        
        return file.data
    }
    
    // MARK: - Get File
    
    public func file(_ name: String) throws -> File {
        guard let file = files.first(where: { $0.filename == name }) else {
            throw PackageDecodingError.fileNotFound
        }
        
        return file
    }
    
    public func file(_ name: String) -> File? {
        return files.first(where: { $0.filename == name })
    }
    
    // MARK: - Get Decodable
    
    public func file<T: Decodable>(_ name: String) throws -> T? {
        guard let file = files.first(where: { $0.filename == name }) else { return nil }
        return try file.decode()
    }
    
    public func file<T: Decodable>(_ name: String) throws -> T {
        guard let file = files.first(where: { $0.filename == name }) else {
            throw PackageDecodingError.fileNotFound
        }
        
        return try file.decode()
    }
    
    public func fileArray<T: Decodable>() throws -> [T] {
        var files: [T] = []
        
        for file in self.files {
            let file: T = try file.decode()
            files.append(file)
        }
        
        return files
    }
    
    public func fileArray<T: Decodable>(_ directoryName: String) throws -> [T] {
        guard let directory = directories.first(where: { $0.name == directoryName }) else {
            throw PackageDecodingError.directoryNotFound
        }
        
        return try directory.fileArray()
    }
    
    // MARK: - Get DiskDecodable
    
    public func file<T: DiskDecodable>(_ name: String) throws -> T? {
        guard let file = files.first(where: { $0.filename == name }) else { return nil }
        
        do {
            return try file.decode()
        } catch let error {
            throw PackageDecodingError.unableToDecodeFile(cause: error)
        }
    }
    
    public func file<T: DiskDecodable>(_ name: String) throws -> T {
        guard let file = files.first(where: { $0.filename == name }) else {
            throw PackageDecodingError.fileNotFound
        }
        
        return try file.decode()
    }
    
    public func fileArray<T: DiskDecodable>() throws -> [T] {
        var files: [T] = []
        
        for file in self.files {
            do {
                let file: T = try file.decode()
                files.append(file)
            } catch let error {
                throw PackageDecodingError.unableToDecodeFile(cause: error)
            }
        }
        
        return files
    }
    
    public func fileArray<T: DiskDecodable>(_ directoryName: String) throws -> [T] {
        guard let directory = directories.first(where: { $0.name == directoryName }) else {
            throw PackageDecodingError.directoryNotFound
        }
        
        return try directory.fileArray()
    }
    
    // MARK: - Get Image
    
    public func image(_ name: String) throws -> UIImage {
        let file: File = try self.file(name)
        
        guard let image = file.image() else {
            throw PackageDecodingError.unableToDecodeFile(cause: nil)
        }
        
        return image
    }
    
    public func image(_ name: String) throws -> UIImage? {
        guard let file = files.first(where: { $0.filename == name }) else { return nil }
        
        guard let image = file.image() else {
            throw PackageDecodingError.unableToDecodeFile(cause: nil)
        }
        
        return image
    }
    
    // MARK: - Get Directory
    
    public func directory(_ name: String) throws -> Directory {
        guard let directory = directories.first(where: { $0.name == name }) else {
            throw PackageDecodingError.directoryNotFound
        }
        
        return directory
    }
    
    // MARK: - Get Text
    
    public func text(_ name: String, encoding: String.Encoding) throws -> String {
        let file: File = try self.file(name)
        
        guard let text = file.text(encoding: encoding) else {
            throw PackageDecodingError.unableToDecodeFile(cause: nil)
        }
        
        return text
    }
    
    public func text(_ name: String, encoding: String.Encoding) throws -> String? {
        guard let file = files.first(where: { $0.filename == name }) else { return nil }
        
        guard let text = file.text(encoding: encoding) else {
            throw PackageDecodingError.unableToDecodeFile(cause: nil)
        }
        
        return text
    }
    
    public func makeFileWrapper() throws -> FileWrapper {
        var fileWrappers: [String: FileWrapper] = [:]
        
        for file in files {
            fileWrappers[file.filename] = file.makeFileWrapper()
        }
        
        for (directory) in directories {
            fileWrappers[directory.name] = try directory.makeFileWrapper()
        }
        
        return FileWrapper(directoryWithFileWrappers: fileWrappers)
    }
}
