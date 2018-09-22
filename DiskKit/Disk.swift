//
//  Disk.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-08.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public typealias Folder = String

public enum WriteError: LocalizedError {
    case encodeFailure
    case storeFailure
}

public enum ReadError: LocalizedError {
    case decodeFailure
    case loadFailure
}

public class Disk {
    private init() { }
    
    public enum Directory {
        /// Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents
        
        /// Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        case caches
        
        /**
         * Returns the search path for the directory
         */
        public var searchPathDirectory: FileManager.SearchPathDirectory {
            switch self {
            case .documents : return .documentDirectory
            case .caches    : return .cachesDirectory
            }
        }
        
        /**
         * Returns URL constructed from specified directory
         */
        public var baseUrl: URL {
            if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
                return url
            } else {
                fatalError("Could not create URL for specified directory!")
            }
        }
        
        public func makeUrl(path: String? = nil, filename: String? = nil) -> URL {
            var url = baseUrl
            
            if let path = path {
                url = url.appendingPathComponent(path, isDirectory: true)
            }
            
            if let filename = filename {
                url = url.appendingPathComponent(filename, isDirectory: false)
            }
            
            return url
        }
        
        public func makeUrl(paths: [String], filename: String? = nil) -> URL {
            let path = paths.joined(separator: "/")
            return makeUrl(path: path, filename: filename)
        }
    }
    
    // MARK: - DiskData
    
    /**
     * Save the disk data to the directory specified
     */
    public static func store(_ diskData: DiskData, to directory: Directory, path: String? = nil) throws -> URL {
        return try store(fileData: diskData.data, to: directory, filename: diskData.filename, path: path)
    }

    /**
     * Retrieve the disk data in the directory specified with the given file name
     */
    public static func diskData(withName filename: String, in directory: Directory, path: String? = nil) throws -> DiskData? {
        guard let data = fileData(withName: filename, in: directory, path: path) else { return nil }
        return DiskData(data: data, name: filename)
    }
    
    /**
     * Retrieve all disk data at specified directory
     */
    public static func diskDataArray(in directory: Directory, path: String? = nil) throws -> [DiskData] {
        let urls = try contents(of: directory, path: path)
        
        let diskDatas: [DiskData] = urls.compactMap({
            let filename = $0.lastPathComponent
            return try? self.diskData(withName: filename, in: directory, path: path)!
        })
        
        return diskDatas
    }
    
    // MARK: - Files
    
    /**
     * Stores a file in the directoy specified. Replaces any file with the same name.
     */
    @discardableResult public static func store(fileData data: Data, to directory: Directory, filename: String, path: String? = nil) throws -> URL {
        let url = directory.makeUrl(path: path, filename: filename)
        try store(fileData: data, to: url)
        return url
    }
    
    /**
     * Returns a file with the given file name in the specified directory.
     */
    public static func fileData(withName filename: String, in directory: Directory, path: String? = nil) -> Data? {
        let url = directory.makeUrl(path: path, filename: filename)
        return fileData(at: url)
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func fileDataArray(in directory: Directory, path: String? = nil) throws -> [Data] {
        let urls = try contents(of: directory, path: path)
        return urls.compactMap({ self.fileData(at: $0) })
    }
    
    /**
     * Remove specified file from specified directory
     */
    public static func remove(filename: String, from directory: Directory, path: String? = nil) {
        let url = directory.makeUrl(path: path, filename: filename)
        removeFile(at: url)
    }
    
    /**
     * Returns BOOL indicating whether file exists at specified directory with specified file name
     */
    public static func fileExists(in directory: Directory, withFileName filename: String, path: String? = nil) -> Bool {
        let url = directory.makeUrl(paths: [path, filename].compactMap({ $0 }))
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /**
     * Returns BOOL indicating whether file exists at specified directory with specified file name
     */
    public static func pathExists(_ path: String, in directory: Directory) -> Bool {
        let url = directory.makeUrl(path: path)
        return pathExists(at: url)
    }
    
    // MARK: - Folders
    
    /**
     * Remove all files at specified directory
     */
    @discardableResult public static func clear(_ directory: Directory, path: String? = nil) throws -> URL {
        let url = directory.makeUrl(path: path)
        try clearContentsOfDirectory(at: url)
        return url
    }
    
    /**
     * Remove all files at specified directory
     */
    public static func remove(path: String, in directory: Directory) throws {
        let url = try clear(directory, path: path)
        
        if !path.isEmpty {
            try FileManager.default.removeItem(at: url)
        }
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func contents(of directory: Directory, path: String? = nil) throws -> [URL] {
        let url = directory.makeUrl(path: path)
        return try self.contentsOfDirectory(at: url)
    }
    
    /**
     * Creates a subfolder in the specified directory.  Does nothing if it already exists.
     */
    @discardableResult public static func create(path: String, in directory: Directory) throws -> URL {
        let url = directory.makeUrl(path: path)
        try self.createDirectory(at: url)
        return url
    }
    
    // MARK - URL
    
    /**
     * Creates a subfolder in the specified directory.  Does nothing if it already exists.
     */
    public static func createDirectory(at url: URL) throws {
        var isDirectory: ObjCBool = false
        
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } else if !isDirectory.boolValue {
            // TODO: Throw path is not directory error
        }
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func contentsOfDirectory(at url: URL) throws -> [URL] {
        let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [])
        return urls
    }
    
    /**
     * Returns BOOL indicating whether file exists at specified url
     */
    public static func fileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /**
     * Checks if the directory exists.
     */
    public static func pathExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        } else {
            return false
        }
    }
    
    /**
     * Stores a file to the url specified. Replaces any file with the same name.
     */
    public static func store(fileData data: Data, to url: URL) throws {
        removeFile(at: url)
        
        if !FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil) {
            throw WriteError.storeFailure
        }
    }
    
    /**
     * Deletes a file at the specfied url.
     */
    public static func removeFile(at url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    /**
     * Returns a file at the specified url.
     */
    public static func fileData(at url: URL) -> Data? {
        let data = FileManager.default.contents(atPath: url.path)
        return data
    }
    
    /**
     * Remove all files at specified directory
     */
    public static func clearContentsOfDirectory(at url: URL) throws {
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        
        for fileUrl in contents {
            try FileManager.default.removeItem(at: fileUrl)
        }
    }
}
