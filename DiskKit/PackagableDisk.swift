//
//  PackagableDisk.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-09.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public enum PackageReadError: LocalizedError {
    case fileNotFound
}

public class PackageMap {
    var files: [DiskData] = []
    
    init() {}
    
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
    }
}

public protocol Package {
    init(map: PackageMap) throws
    func mapping(map: PackageMap) throws
}

extension Package {
    
    func makeFileWrapper() throws -> FileWrapper {
        let map = PackageMap()
        try mapping(map: map)
        var fileWrappers: [String: FileWrapper] = [:]
        
        for file in map.files {
            fileWrappers[file.fileName] = file.makeFileWrapper()
        }
        
        return FileWrapper(directoryWithFileWrappers: fileWrappers)
    }
}

public class PackagableDisk {
    
    /**
     * Store an package to the specified directory on disk
     * @package: the package to store
     * @directory: where to store the struct
     * @packageName: what to name the package where the folder will be stored
     */
    public static func store(_ package: Package, to directory: Disk.Directory, withName packageName: String, path: String? = nil) throws -> URL {
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
    public static func package<T: Package>(withName packageName: String, in directory: Disk.Directory, path: String? = nil) throws -> T? {
        let packageUrl = directory.makeUrl(paths: [path, packageName].compactMap({ $0 }))
        let fileWrapper = try FileWrapper(url: packageUrl, options: [])
        guard fileWrapper.isDirectory else { return nil }
        let map = PackageMap()
        
        for (fileName, subFileWrapper) in fileWrapper.fileWrappers ?? [:] {
            guard let data = subFileWrapper.regularFileContents else { continue }
            map.add(DiskData(data: data, name: fileName))
        }
        
        return try T(map: map)
    }
    
    static func packages<T: Package>(in directory: Disk.Directory, path: String? = nil) throws -> [T] {
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
