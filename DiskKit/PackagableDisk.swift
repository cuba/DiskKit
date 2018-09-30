//
//  PackagableDisk.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-09.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public class PackagableDisk {
    
    /**
     * Store an directory to the specified directory on disk
     * @directory: the directory to store
     * @to: the directory where to store the directory
     * @as: the name to store the directory as
     * @path: the path in the directory to store the file in. The filename will be appended to this path.
     * @originalUrl: the original url of the directory.
     */
    public static func store(_ package: Package, to directory: Disk.Directory, as filename: String, path: String? = nil, options: FileWrapper.WritingOptions = [.withNameUpdating, .atomic], originalUrl: URL? = nil) throws -> URL {
        let url = directory.makeUrl(path: path, filename: filename)
        try store(package, to: url, options: options, originalUrl: originalUrl)
        return url
    }
    
    /**
     * Retrieve and convert a packages from a folder on disk
     * @packageName: name of the directory where folder is stored
     * @directory: directory where directory data is stored
     * @Returns: decoded directory
     */
    public static func packages<T: Package>(in directory: Disk.Directory, path: String? = nil, options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants]) throws -> [T] {
        let url = directory.makeUrl(path: path)
        return try packages(in: url, options: options)
    }
    
    /**
     * Retrieve and convert a directory from a folder on disk
     * @packageName: name of the directory where folder is stored
     * @directory: directory where directory data is stored
     * @Returns: decoded directory
     */
    public static func package<T: Package>(withName name: String, in directory: Disk.Directory, path: String? = nil) throws -> T? {
        let url = directory.makeUrl(paths: [path, name].compactMap({ $0 }))
        return try package(at: url)
    }
    
    /**
     * Store an directory to the specified directory on disk
     * @directory: the directory to store
     * @url: where to store the struct
     * @orignalUrl: the original location of the directory (you should provide this if you're updating an existing directory)
     */
    public static func store(_ package: Package, to url: URL, options: FileWrapper.WritingOptions = [.withNameUpdating, .atomic], originalUrl: URL? = nil) throws {
        let fileWrapper = try package.makeFileWrapper(saveUrl: url)
        try fileWrapper.write(to: url, options: options, originalContentsURL: originalUrl)
        
        #if DEBUG
        if originalUrl != nil {
            print("Updated directory in \(url)")
        } else {
            print("Saved directory to \(url)")
        }
        #endif
    }
    
    /**
     * Retrieve and convert a packagabe from a folder on disk
     * @url: url where directory data is stored
     * @Returns: decoded directory
     */
    public static func package<T: Package>(at url: URL) throws -> T? {
        guard let directory = try directory(at: url) else { return nil }
        return try T(directory: directory)
    }
    
    /**
     * Retrieve and convert a directory from a folder on disk
     * @url: url where directory is stored
     * @options: Default value is [.skipsPackageDescendants]
     * @Returns: A list of packages
     */
    public static func packages<T: Package>(in url: URL, options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants]) throws -> [T] {
        let directories = self.directories(in: url, options: options, typeIdentifier: T.typeIdentifier)
        var packages: [T] = []
        
        for directory in directories {
            do {
                let package = try T(directory: directory)
                packages.append(package)
            } catch let error {
                print(error)
            }
        }
        
        return packages
    }
    
    /**
     * Retrieve and convert a directory from a folder on disk
     * @url: url where directory is stored
     * @options: Directory enumeration options
     * @typeIdentifier: The identifier of the file defined in the Info.plist file under UTTypeIdentifier
     * @Returns: A directory
     */
    public static func directories(in url: URL, options: FileManager.DirectoryEnumerationOptions = [], typeIdentifier: String? = nil) -> [Directory] {
        var resourceKeys: [URLResourceKey] = []
        var directories: [Directory] = []
        var lastUrl: URL?
        
        if typeIdentifier != nil {
            resourceKeys.append(.typeIdentifierKey)
        }
        
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: resourceKeys, options: options) else { return [] }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                
                if let typeIdentifier = typeIdentifier {
                    guard resourceValues.typeIdentifier == typeIdentifier.lowercased() else { continue }
                } else {
                    guard !(lastUrl?.isParent(of: fileURL) ?? false) else { continue }
                    lastUrl = fileURL
                }
                
                guard let directory = try self.directory(at: fileURL) else { continue }
                directories.append(directory)
            } catch let error {
                print(error)
                // TODO: Handle this?
            }
        }
        
        return directories
    }
    
    /**
     * Retrieve and convert a directory from a folder on disk
     * @url: url where directory data is stored
     * @Returns: decoded directory
     */
    public static func directory(at url: URL) throws -> Directory? {
        let fileWrapper: FileWrapper
        let resourceKeys: [URLResourceKey] = [.typeIdentifierKey]
        let resourceValues: URLResourceValues
        
        do {
            resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))
            fileWrapper = try FileWrapper(url: url, options: [.immediate])
        } catch let error {
            throw PackageDecodingError.unableToDecodeFile(cause: error)
        }
        
        guard fileWrapper.isDirectory else {
            throw PackageDecodingError.notFolder
        }
        
        return Directory(fileWrapper, saveUrl: url, typeIdentifier: resourceValues.typeIdentifier)
    }
}
