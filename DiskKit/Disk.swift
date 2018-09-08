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
    }
    
    /**
     * Store an encodable struct to the specified directory on disk
     * @object: the encodable struct to store
     * @directory: where to store the struct
     * @fileName: what to name the file where the struct data will be stored
     */
    @discardableResult public static func store<T: Serializable>(_ object: T, to directory: Directory, as fileName: String) throws -> URL {
        let data = try object.encode()
        
        guard let url = store(data, withFileName: fileName, to: directory) else {
            throw WriteError.storeFailure
        }
        
        return url
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
        var searchPathDirectory: FileManager.SearchPathDirectory
        
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }
        
        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
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
        remove(fileAtUrl: url)
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
    @discardableResult public static func store(_ data: Data, withFileName fileName: String, to directory: Directory) -> URL? {
        let url = getURL(forFileName: fileName, in: directory)
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                assertionFailure(error.localizedDescription)
                return nil
            }
        }
        
        FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        return url
    }
    
    /**
     * Deletes a file at the specfied url.
     */
    public static func remove(fileAtUrl url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    /**
     * Returns a file with the given file name in the specified directory.
     */
    public static func retrieve(fileWithName fileName: String, in directory: Directory) -> Data? {
        let url = getURL(forFileName: fileName, in: directory)
        return retrieve(fileAtUrl: url)
    }
    
    /**
     * Returns a file at the specified directory.
     */
    public static func retrieve(fileAtUrl url: URL) -> Data? {
        let data = FileManager.default.contents(atPath: url.path)
        return data
    }
}
