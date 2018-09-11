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
        
        public func makeUrl(path: String? = nil, fileName: String? = nil) -> URL {
            var url = baseUrl
            
            if let path = path {
                url = url.appendingPathComponent(path, isDirectory: true)
            }
            
            if let fileName = fileName {
                url = url.appendingPathComponent(fileName, isDirectory: false)
            }
            
            return url
        }
        
        public func makeUrl(paths: [String], fileName: String? = nil) -> URL {
            let path = paths.joined(separator: "/")
            return makeUrl(path: path, fileName: fileName)
        }
    }
    
    // MARK: - DiskData
    
    /**
     * Save the disk data to the directory specified
     */
    public static func store(_ diskData: DiskData, to directory: Directory, path: String? = nil) throws -> URL {
        return try store(fileData: diskData.data, to: directory, fileName: diskData.fileName, path: path)
    }

    /**
     * Retrieve the disk data in the directory specified with the given file name
     */
    public static func diskData(withName fileName: String, in directory: Directory, path: String? = nil) throws -> DiskData? {
        guard let data = fileData(withName: fileName, in: directory, path: path) else { return nil }
        return DiskData(data: data, name: fileName)
    }
    
    /**
     * Retrieve all disk data at specified directory
     */
    public static func diskDataArray(in directory: Directory, path: String? = nil) throws -> [DiskData] {
        let urls = try contents(of: directory, path: path)
        var diskDatas: [DiskData] = []
        
        for url in urls {
            let fileName = url.lastPathComponent
            guard let data = self.fileData(at: url) else { continue }
            diskDatas.append(DiskData(data: data, name: fileName))
        }
        
        return diskDatas
    }
    
    // MARK: - Directory
    
    /**
     * Stores a file in the directoy specified. Replaces any file with the same name.
     */
    @discardableResult public static func store(fileData data: Data, to directory: Directory, fileName: String, path: String? = nil) throws -> URL {
        let url = directory.makeUrl(path: path, fileName: fileName)
        try store(fileData: data, to: url)
        return url
    }
    
    /**
     * Returns a file with the given file name in the specified directory.
     */
    public static func fileData(withName fileName: String, in directory: Directory, path: String? = nil) -> Data? {
        let url = directory.makeUrl(path: path, fileName: fileName)
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
     * Remove all files at specified directory
     */
    @discardableResult public static func clear(_ directory: Directory, path: String? = nil) throws -> URL {
        let url = directory.makeUrl(path: path)
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        
        for fileUrl in contents {
            try FileManager.default.removeItem(at: fileUrl)
        }
        
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
     * Remove specified file from specified directory
     */
    public static func remove(fileName: String, from directory: Directory, path: String? = nil) {
        let url = directory.makeUrl(path: path, fileName: fileName)
        removeFile(at: url)
    }
    
    /**
     * Returns BOOL indicating whether file exists at specified directory with specified file name
     */
    public static func fileExists(in directory: Directory, withFileName fileName: String, path: String? = nil) -> Bool {
        let url = directory.makeUrl(path: path, fileName: fileName)
        return FileManager.default.fileExists(atPath: url.path)
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
}
