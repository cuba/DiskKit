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
     * @directory: where to store the struct
     * @packageName: what to name the package where the folder will be stored
     */
    public static func store(_ package: Packagable, to directory: Disk.Directory, as filename: String, path: String? = nil) throws -> URL {
        let url = directory.makeUrl(path: path, filename: filename)
        try store(package, to: url, originalUrl: url)
        return url
    }
    
    /**
     * Retrieve and convert a packages from a folder on disk
     * @packageName: name of the package where folder is stored
     * @directory: directory where package data is stored
     * @Returns: decoded package
     */
    public static func packages<T: Packagable>(in directory: Disk.Directory, path: String? = nil) throws -> [T] {
        let url = directory.makeUrl(path: path)
        return try packages(in: url)
    }
    
    /**
     * Retrieve and convert a package from a folder on disk
     * @packageName: name of the package where folder is stored
     * @directory: directory where package data is stored
     * @Returns: decoded package
     */
    public static func package<T: Packagable>(withName packageName: String, in directory: Disk.Directory, path: String? = nil) throws -> T? {
        let url = directory.makeUrl(paths: [path, packageName].compactMap({ $0 }))
        return try package(at: url)
    }
    
    /**
     * Store an package to the specified directory on disk
     * @package: the package to store
     * @url: where to store the struct
     * @orignalUrl: the original location of the package (you should provide this if you're updating an existing package)
     */
    public static func store(_ package: Packagable, to url: URL, originalUrl: URL?) throws {
        let filename = url.lastPathComponent
        let fileWrapper = try package.makeFileWrapper(filename: filename)
        try fileWrapper.write(to: url, options: [.withNameUpdating, .atomic], originalContentsURL: originalUrl)
        
        #if DEBUG
        if originalUrl != nil {
            print("Updated package in \(url)")
        } else {
            print("Saved package to \(url)")
        }
        #endif
    }
    
    /**
     * Retrieve and convert a packages from a folder on disk
     * @packageName: name of the package where folder is stored
     * @url: url where package data is stored
     * @options: Default value is [.skipsPackageDescendants, .skipsHiddenFiles]
     * @Returns: decoded package
     */
    public static func packages<T: Packagable>(in url: URL, options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]) throws -> [T] {
        let resourceKeys: [URLResourceKey] = []
        guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: resourceKeys, options: options) else { return [] }
        var packages: [T] = []
        var lastPackageUrl: URL?
        
        for case let fileURL as URL in enumerator {
            do {
                guard lastPackageUrl == nil || !fileURL.absoluteString.hasPrefix(lastPackageUrl!.absoluteString) else { continue }
                // let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                
                guard let package: T = try package(at: fileURL) else {
                    continue
                }
                
                lastPackageUrl = fileURL
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
     * @packageName: name of the package where folder is stored
     * @url: url where package data is stored
     * @Returns: decoded package
     */
    public static func package<T: Packagable>(at url: URL) throws -> T? {
        let fileWrapper: FileWrapper
        
        do {
            fileWrapper = try FileWrapper(url: url, options: [.immediate])
        } catch let error {
            throw PackageDecodingError.unableToDecodeFile(cause: error)
        }
        
        guard fileWrapper.isDirectory else {
            throw PackageDecodingError.notFolder
        }
        
        let package = try Package(fileWrapper, savedUrl: url)
        return try T(package: package)
    }
}
