//
//  Disk.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-08.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public enum WriteError: LocalizedError {
    case encodeFailure
    case storeFailure
}

public enum ReadError: LocalizedError {
    case decodeFailure
    case loadFailure
}

public protocol Serializable {
    init(_ data: Data) throws
    func encode() throws -> Data
}

public protocol StringSerializable: Serializable {
    init(_ string: String) throws
    func encode() throws -> String
}

extension StringSerializable {
    public init(_ data: Data) throws {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ReadError.decodeFailure
        }
        
        try self.init(text)
    }
    
    public func encode() throws -> Data {
        let text: String = try self.encode()
        
        guard let data = text.data(using: .utf8) else {
            throw WriteError.encodeFailure
        }
        
        return data
    }
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
    }
    
    /**
     * Store an encodable struct to the specified directory on disk
     * @object: the encodable struct to store
     * @directory: where to store the struct
     * @fileName: what to name the file where the struct data will be stored
     */
    @discardableResult public static func store<T: Serializable>(_ object: T, to directory: Directory, as fileName: String) throws -> URL {
        let data = try object.encode()
        return try store(fileData: data, withFileName: fileName, to: directory)
    }
    
    /**
     * Retrieve and convert a struct from a file on disk
     * @fileName: name of the file where struct data is stored
     * @directory: directory where struct data is stored
     * @type: struct type (i.e. Message.self)
     * @Returns: decoded struct model(s) of data
     */
    public static func retrieve<T: Serializable>(withFileName fileName: String, from directory: Directory, as type: T.Type) throws -> T {
        if let data = retrieve(fileWithName: fileName, in: directory) {
            let model = try type.init(data)
            return model
        } else {
            throw ReadError.loadFailure
        }
    }
    
    /**
     * Returns URL constructed from specified directory
     */
    public static func getURL(for directory: Directory) -> URL {
        return directory.baseUrl
    }
    
    public static func getURL(forFileName fileName: String, in directory: Directory) -> URL {
        return getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
    }
    
    /**
     * Remove all files at specified directory
     */
    public static func clear(_ directory: Directory) throws {
        let url = getURL(for: directory)
        
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        for fileUrl in contents {
            try FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func files(in directory: Directory) throws -> [URL] {
        let url = getURL(for: directory)
        return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
    }

    
    /**
     * Remove specified file from specified directory
     */
    public static func remove(fileName: String, from directory: Directory) {
        let url = getURL(forFileName: fileName, in: directory)
        removeFile(at: url)
    }
    
    /**
     * Returns BOOL indicating whether file exists at specified directory with specified file name
     */
    public static func fileExists(withFileName fileName: String, in directory: Directory) -> Bool {
        let url = getURL(forFileName: fileName, in: directory)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /**
     * Stores a file in the directoy specified. Replaces any file with the same name.
     */
    @discardableResult public static func store(fileData data: Data, withFileName fileName: String, to directory: Directory) throws -> URL {
        let url = getURL(forFileName: fileName, in: directory)
        try store(fileData: data, to: url)
        return url
    }
    
    /**
     * Returns BOOL indicating whether file exists at specified url
     */
    public static func fileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /**
     * Returns a file with the given file name in the specified directory.
     */
    public static func retrieve(fileWithName fileName: String, in directory: Directory) -> Data? {
        let url = getURL(forFileName: fileName, in: directory)
        return retrieveFile(at: url)
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
    public static func retrieveFile(at url: URL) -> Data? {
        let data = FileManager.default.contents(atPath: url.path)
        return data
    }
}
