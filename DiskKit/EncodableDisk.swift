//
//  EncodableDisk.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-09.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public protocol DiskEncodable {
    func encode() throws -> Data
}

public protocol DiskDecodable {
    init(_ data: Data) throws
}

public protocol DiskCodable: DiskEncodable, DiskDecodable {
}

public class EncodableDisk {
    
    // MARK: - Codable
    
    /**
     * Store an Encodable struct to the specified directory on disk
     * @object: the encodable struct to store
     * @directory: where to store the struct
     * @fileName: what to name the file where the struct data will be stored
     */
    @discardableResult public static func store<T: Encodable>(_ file: T, to directory: Disk.Directory, as fileName: String) throws -> URL {
        let diskData = try DiskData(file: file, fileName: fileName)
        return try Disk.save(diskData, to: directory)
    }
    
    /**
     * Retrieve and convert a struct from a file on disk
     * @fileName: name of the file where struct data is stored
     * @directory: directory where struct data is stored
     * @type: struct type (i.e. Message.self)
     * @Returns: decoded struct model(s) of data
     */
    public static func file<T: Decodable>(withName fileName: String, in directory: Disk.Directory) throws -> T? {
        let diskData = try Disk.diskData(withName: fileName, in: directory)
        return try diskData?.decode()
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func files<T: Decodable>(in directory: Disk.Directory) throws -> [T] {
        let diskDatas = try Disk.diskDatas(in: directory)
        
        return diskDatas.compactMap({
            return try? $0.decode()
        })
    }
    
    // MARK: - DiskCodable
    
    /**
     * Store an encodable struct to the specified directory on disk
     * @object: the encodable struct to store
     * @directory: where to store the struct
     * @fileName: what to name the file where the struct data will be stored
     */
    @discardableResult public static func store<T: DiskEncodable>(_ file: T, to directory: Disk.Directory, as fileName: String) throws -> URL {
        let diskData = try DiskData(file: file, fileName: fileName)
        return try Disk.save(diskData, to: directory)
    }
    
    /**
     * Retrieve and convert a struct from a file on disk
     * @fileName: name of the file where struct data is stored
     * @directory: directory where struct data is stored
     * @type: struct type (i.e. Message.self)
     * @Returns: decoded struct model(s) of data
     */
    public static func file<T: DiskDecodable>(withName fileName: String, in directory: Disk.Directory, subfolder: Folder? = nil) throws -> T? {
        let diskData = try Disk.diskData(withName: fileName, in: directory)
        return try diskData?.decode()
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func files<T: DiskDecodable>(in directory: Disk.Directory, withSubfolder subfolder: Folder? = nil) throws -> [T] {
        let diskDatas = try Disk.diskDatas(in: directory)
        
        return diskDatas.compactMap({
            return try? $0.decode()
        })
    }
}
