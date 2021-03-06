//
//  EncodableDisk.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-09.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public class EncodableDisk {
    
    // MARK: - Codable
    
    /**
     * Store an Encodable struct to the specified directory on disk
     * @object: the encodable struct to store
     * @directory: where to store the struct
     * @filename: what to name the file where the struct data will be stored
     */
    @discardableResult public static func store<T: Encodable>(_ file: T, to directory: Disk.Directory, as filename: String, path: String? = nil) throws -> URL {
        let file = try File(file: file, name: filename)
        return try Disk.store(file, to: directory, path: path)
    }
    
    /**
     * Retrieve and convert a struct from a file on disk
     * @filename: name of the file where struct data is stored
     * @directory: directory where struct data is stored
     * @type: struct type (i.e. Message.self)
     * @Returns: decoded struct model(s) of data
     */
    public static func file<T: Decodable>(withName filename: String, in directory: Disk.Directory, path: String? = nil) throws -> T? {
        let file = try Disk.file(withName: filename, in: directory, path: path)
        return try file?.decode()
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func files<T: Decodable>(in directory: Disk.Directory, path: String? = nil) throws -> [T] {
        let files = try Disk.filesArray(in: directory, path: path)
        
        return files.compactMap({
            return try? $0.decode()
        })
    }
    
    // MARK: - DiskCodable
    
    /**
     * Store an encodable struct to the specified directory on disk
     * @object: the encodable struct to store
     * @directory: where to store the struct
     * @filename: what to name the file where the struct data will be stored
     */
    @discardableResult
    public static func store<T: DiskEncodable>(_ file: T, to directory: Disk.Directory, as filename: String, path: String? = nil) throws -> URL {
        let file = try File(file: file, name: filename)
        return try Disk.store(file, to: directory, path: path)
    }
    
    /**
     * Retrieve and convert a struct from a file on disk
     * @filename: name of the file where struct data is stored
     * @directory: directory where struct data is stored
     * @type: struct type (i.e. Message.self)
     * @Returns: decoded struct model(s) of data
     */
    public static func file<T: DiskDecodable>(withName filename: String, in directory: Disk.Directory, path: String? = nil) throws -> T? {
        let file = try Disk.file(withName: filename, in: directory, path: path)
        return try file?.decode()
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func files<T: DiskDecodable>(in directory: Disk.Directory, withSubfolder path: String? = nil) throws -> [T] {
        let files = try Disk.filesArray(in: directory, path: path)
        
        return files.compactMap({
            return try? $0.decode()
        })
    }
}
