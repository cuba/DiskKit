//
//  PackagableDisk.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-09.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public protocol Packagable {
    init(package: Package) throws
    func fill(package: Package) throws
}

public extension Packagable {
    
    public func makeFileWrapper() throws -> FileWrapper {
        let package = Package()
        try fill(package: package)
        return try package.makeFileWrapper()
    }
}

public class PackagableDisk {
    
    /**
     * Store an package to the specified directory on disk
     * @package: the package to store
     * @directory: where to store the struct
     * @packageName: what to name the package where the folder will be stored
     */
    public static func store(_ package: Packagable, to directory: Disk.Directory, withName packageName: String, path: String? = nil) throws -> URL {
        let fileWrapper = try package.makeFileWrapper()
        let packageUrl = directory.makeUrl(paths: [path, packageName].compactMap({ $0 }))
        try fileWrapper.write(to: packageUrl, options: [], originalContentsURL: nil)
        return packageUrl
    }
    
    /**
     * Retrieve and convert a package from a folder on disk
     * @packageName: name of the package where folder is stored
     * @directory: directory where package data is stored
     * @Returns: decoded package
     */
    public static func package<T: Packagable>(withName packageName: String, in directory: Disk.Directory, path: String? = nil) throws -> T? {
        let packageUrl = directory.makeUrl(paths: [path, packageName].compactMap({ $0 }))
        let fileWrapper = try FileWrapper(url: packageUrl, options: [])
        let package = try Package(fileWrapper)
        return try T(package: package)
    }
    
    public static func packages<T: Packagable>(in directory: Disk.Directory, path: String? = nil) throws -> [T] {
        let packageUrls = try Disk.contents(of: directory, path: path)
        let packageNames = packageUrls.map({ $0.lastPathComponent })
        var packages: [T] = []
        
        for packageName in packageNames {
            do {
                guard let file: T = try self.package(withName: packageName, in: directory, path: path) else { continue }
                
                packages.append(file)
            } catch {
                // Handle this?
            }
        }
        
        return packages
    }
}
