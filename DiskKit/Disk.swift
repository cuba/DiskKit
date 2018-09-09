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

public protocol DiskEncodable {
    func encode() throws -> Data
}

public protocol DiskDecodable {
    init(_ data: Data) throws
}

public protocol DiskCodable: DiskEncodable, DiskDecodable{
    
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
    @discardableResult public static func store<T: DiskEncodable>(_ file: T, to directory: Directory, as fileName: String) throws -> URL {
        let data = try file.encode()
        return try store(fileData: data, withFileName: fileName, to: directory)
    }
    
    /**
     * Store an Encodable struct to the specified directory on disk
     * @object: the encodable struct to store
     * @directory: where to store the struct
     * @fileName: what to name the file where the struct data will be stored
     */
    @discardableResult public static func store<T: Encodable>(_ file: T, to directory: Directory, as fileName: String) throws -> URL {
        let encoder = JSONEncoder()
        let data = try encoder.encode(file)
        return try store(fileData: data, withFileName: fileName, to: directory)
    }
    
    /**
     * Retrieve and convert a struct from a file on disk
     * @fileName: name of the file where struct data is stored
     * @directory: directory where struct data is stored
     * @type: struct type (i.e. Message.self)
     * @Returns: decoded struct model(s) of data
     */
    public static func file<T: Decodable>(withName fileName: String, in directory: Directory) throws -> T? {
        if let data = fileData(withName: fileName, in: directory) {
            let decoder = JSONDecoder()
            let file = try decoder.decode(T.self, from: data)
            return file
        } else {
            return nil
        }
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func files<T: Decodable>(in directory: Directory) throws -> [T] {
        let datas = try filesDatas(in: directory)
        var files: [T] = []
        
        for data in datas {
            let decoder = JSONDecoder()
            guard let file = try? decoder.decode(T.self, from: data) else { continue }
            files.append(file)
        }
        
        return files
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func files<T: DiskDecodable>(in directory: Directory) throws -> [T] {
        let datas = try filesDatas(in: directory)
        var files: [T] = []
        
        for data in datas {
            guard let file = try? T(data) else { continue }
            files.append(file)
        }
        
        return files
    }
    
    /**
     * Retrieve and convert a struct from a file on disk
     * @fileName: name of the file where struct data is stored
     * @directory: directory where struct data is stored
     * @type: struct type (i.e. Message.self)
     * @Returns: decoded struct model(s) of data
     */
    public static func file<T: DiskDecodable>(withName fileName: String, in directory: Directory) throws -> T? {
        if let data = fileData(withName: fileName, in: directory) {
            let model = try T(data)
            return model
        } else {
            return nil
        }
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func filesDatas(in directory: Directory) throws -> [Data] {
        let urls = try fileUrls(in: directory)
        return urls.map({ self.fileData(at: $0)! })
    }
    
    public static func getURL(forFileName fileName: String, in directory: Directory) -> URL {
        return directory.baseUrl.appendingPathComponent(fileName, isDirectory: false)
    }
    
    /**
     * Remove all files at specified directory
     */
    public static func clear(_ directory: Directory) throws {
        let url = directory.baseUrl
        
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        for fileUrl in contents {
            try FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func fileUrls(in directory: Directory) throws -> [URL] {
        let url = directory.baseUrl
        let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [])
        return urls
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
    
    public static func create(subfolder: Folder, in directory: Directory) throws -> URL {
        let url = directory.baseUrl.appendingPathComponent(subfolder, isDirectory: true)
        var isDirectory: ObjCBool = false
        
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
    
    /**
     * Returns a file with the given file name in the specified directory.
     */
    public static func fileData(withName fileName: String, in directory: Directory) -> Data? {
        let url = getURL(forFileName: fileName, in: directory)
        return fileData(at: url)
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
