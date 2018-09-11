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

public protocol Package {
    init(map: PackageMap) throws
    func mapping(map: PackageMap) throws
}

public class PackagableDisk {
    
    /**
     * Store an package to the specified directory on disk
     * @package: the package to store
     * @directory: where to store the struct
     * @packageName: what to name the package where the folder will be stored
     */
    public static func store(_ package: Package, to directory: Disk.Directory, withName packageName: String, path: String? = nil) throws -> URL {
        let packageUrl = directory.makeUrl(paths: [path, packageName].compactMap({ $0 }))
        let resourcesUrl = packageUrl.appendingPathComponent("/Resources")
        try Disk.createDirectory(at: resourcesUrl)
        
        let map = PackageMap()
        try package.mapping(map: map)
        
        for file in map.files {
            let fileName = file.fileName
            let url = resourcesUrl.appendingPathComponent(fileName)
            try Disk.store(fileData: file.data, to: url)
        }
        
        return packageUrl
    }
    
    /**
     * Retrieve and convert a package from a folder on disk
     * @packageName: name of the package where folder is stored
     * @directory: directory where package data is stored
     * @Returns: decoded package
     */
    public static func package<T: Package>(withName packageName: String, in directory: Disk.Directory, path: String? = nil) throws -> T? {
        let resourcesUrl = directory.makeUrl(paths: [path, packageName, "Resources"].compactMap({ $0 }))
        let fileUrls = try Disk.contentsOfDirectory(at: resourcesUrl)
        let map = PackageMap()
        
        for fileUrl in fileUrls {
            guard let data = Disk.fileData(at: fileUrl) else { continue }
            let file = DiskData(data: data, name: fileUrl.lastPathComponent)
            map.add(file)
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
