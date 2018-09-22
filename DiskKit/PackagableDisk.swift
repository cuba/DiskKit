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
     * Store an package to the specified directory on disk
     * @package: the package to store
     * @to: the directory where to store the package
     * @as: the name to store the package as
     * @path: the path in the directory to store the file in. The filename will be appended to this path.
     * @originalUrl: the original url of the package.
     */
    public static func store(_ package: Packagable, to directory: Disk.Directory, as filename: String, path: String? = nil, options: FileWrapper.WritingOptions = [.withNameUpdating, .atomic], originalUrl: URL? = nil) throws -> URL {
        let url = directory.makeUrl(path: path, filename: filename)
        try store(package, to: url, originalUrl: originalUrl)
        return url
    }
    
    /**
     * Retrieve and convert a packages from a folder on disk
     * @packageName: name of the package where folder is stored
     * @directory: directory where package data is stored
     * @Returns: decoded package
     */
    public static func packagables<T: Packagable>(in directory: Disk.Directory, path: String? = nil) throws -> [T] {
        let url = directory.makeUrl(path: path)
        return try packagables(in: url)
    }
    
    /**
     * Retrieve and convert a package from a folder on disk
     * @packageName: name of the package where folder is stored
     * @directory: directory where package data is stored
     * @Returns: decoded package
     */
    public static func packagable<T: Packagable>(withName packageName: String, in directory: Disk.Directory, path: String? = nil) throws -> T? {
        let url = directory.makeUrl(paths: [path, packageName].compactMap({ $0 }))
        return try packagable(at: url)
    }
    
    /**
     * Store an package to the specified directory on disk
     * @package: the package to store
     * @url: where to store the struct
     * @orignalUrl: the original location of the package (you should provide this if you're updating an existing package)
     */
    public static func store(_ package: Packagable, to url: URL, options: FileWrapper.WritingOptions = [.withNameUpdating, .atomic], originalUrl: URL? = nil) throws {
        let fileWrapper = try package.makeFileWrapper(saveUrl: url)
        try fileWrapper.write(to: url, options: options, originalContentsURL: originalUrl)
        
        #if DEBUG
        if originalUrl != nil {
            print("Updated package in \(url)")
        } else {
            print("Saved package to \(url)")
        }
        #endif
    }
    
    /**
     * Retrieve and convert a packagables from a folder on disk
     * @url: url where package data is stored
     * @options: Default value is [.skipsPackageDescendants, .skipsHiddenFiles]
     * @Returns: decoded package
     */
    public static func packagables<T: Packagable>(in url: URL, options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]) throws -> [T] {
        var packagables: [T] = []
        
        for package in try packages(in: url, options: options) {
            do {
                let packagable = try T(package: package)
                packagables.append(packagable)
            } catch let error {
                print(error)
                // TODO: Handle this?
            }
        }
        
        return packagables
    }
    
    /**
     * Retrieve and convert a packagabe from a folder on disk
     * @url: url where package data is stored
     * @Returns: decoded package
     */
    public static func packagable<T: Packagable>(at url: URL) throws -> T? {
        guard let package = try package(at: url) else { return nil }
        return try T(package: package)
    }
    
    /**
     * Retrieve and convert a packages from a folder on disk
     * @url: url where package data is stored
     * @options: Default value is [.skipsPackageDescendants, .skipsHiddenFiles]
     * @Returns: decoded package
     */
    public static func packages(in url: URL, options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]) throws -> [Package] {
        let resourceKeys: [URLResourceKey] = [.isPackageKey]
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: resourceKeys, options: options) else { return [] }
        var packages: [Package] = []
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                guard resourceValues.isPackage ?? false else { continue }
                guard let package = try package(at: fileURL) else { continue }
                packages.append(package)
            } catch let error {
                print(error)
                // TODO: Handle this?
            }
        }
        
        return packages
    }
    
    /**
     * Retrieve and convert a package from a folder on disk
     * @url: url where package data is stored
     * @Returns: decoded package
     */
    public static func package(at url: URL) throws -> Package? {
        let fileWrapper: FileWrapper
        
        do {
            fileWrapper = try FileWrapper(url: url, options: [.immediate])
        } catch let error {
            throw PackageDecodingError.unableToDecodeFile(cause: error)
        }
        
        guard fileWrapper.isDirectory else {
            throw PackageDecodingError.notFolder
        }
        
        return try Package(fileWrapper, savedUrl: url)
    }
}
