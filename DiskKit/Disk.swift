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

public protocol DiskPackage {
    init(files: [String: DiskData])
    func encode() throws -> [String: DiskData]
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
        
        func baseUrl(withSubfolder subfolder: Folder? = nil) -> URL {
            var url = baseUrl
            
            if let subfolder = subfolder {
                url = url.appendingPathComponent(subfolder, isDirectory: true)
            }
            
            return url
        }
    }
    
    // MARK: - DiskData
    
    public static func save(_ diskData: DiskData, to directory: Directory, subfolder: Folder? = nil) throws -> URL {
        return try store(fileData: diskData.data, withFileName: diskData.fileName, to: directory, subfolder: subfolder)
    }
    
    public static func diskData(withName fileName: String, in directory: Directory, subfolder: Folder? = nil) throws -> DiskData? {
        guard let data = fileData(withName: fileName, in: directory, subfolder: subfolder) else { return nil }
        return DiskData(data: data, fileName: fileName)
    }
    
    public static func diskDatas(in directory: Directory, subfolder: Folder? = nil) throws -> [DiskData] {
        let urls = try fileUrls(in: directory, subfolder: subfolder)
        var diskDatas: [DiskData] = []
        
        for url in urls {
            let fileName = url.lastPathComponent
            guard let data = self.fileData(at: url) else { continue }
            diskDatas.append(DiskData(data: data, fileName: fileName))
        }
        
        return diskDatas
    }
    
    // MARK: - Directory
    
    /**
     * Retrieve all files at specified directory
     */
    public static func filesDatas(in directory: Directory, subfolder: Folder? = nil) throws -> [Data] {
        let urls = try fileUrls(in: directory, subfolder: subfolder)
        return urls.compactMap({ self.fileData(at: $0) })
    }
    
    /**
     * Stores a file in the directoy specified. Replaces any file with the same name.
     */
    @discardableResult public static func store(fileData data: Data, withFileName fileName: String, to directory: Directory, subfolder: Folder? = nil) throws -> URL {
        let url = getURL(forFileName: fileName, in: directory, subfolder: subfolder)
        try store(fileData: data, to: url)
        return url
    }
    
    /**
     * Returns a file with the given file name in the specified directory.
     */
    public static func fileData(withName fileName: String, in directory: Directory, subfolder: Folder? = nil) -> Data? {
        let url = getURL(forFileName: fileName, in: directory, subfolder: subfolder)
        return fileData(at: url)
    }
    
    public static func getURL(forFileName fileName: String, in directory: Directory, subfolder: Folder? = nil) -> URL {
        let url = directory.baseUrl(withSubfolder: subfolder)
        return url.appendingPathComponent(fileName, isDirectory: false)
    }
    
    /**
     * Remove all files at specified directory
     */
    public static func clear(_ directory: Directory, subfolder: Folder? = nil) throws {
        let url = directory.baseUrl(withSubfolder: subfolder)
        
        let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        for fileUrl in contents {
            try FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    /**
     * Retrieve all files at specified directory
     */
    public static func fileUrls(in directory: Directory, subfolder: Folder? = nil) throws -> [URL] {
        let url = directory.baseUrl(withSubfolder: subfolder)
        let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [])
        return urls
    }
    
    /**
     * Remove specified file from specified directory
     */
    public static func remove(fileName: String, from directory: Directory, subfolder: Folder? = nil) {
        let url = getURL(forFileName: fileName, in: directory, subfolder: subfolder)
        removeFile(at: url)
    }
    
    /**
     * Returns BOOL indicating whether file exists at specified directory with specified file name
     */
    public static func fileExists(withFileName fileName: String, in directory: Directory, subfolder: Folder? = nil) -> Bool {
        let url = getURL(forFileName: fileName, in: directory, subfolder: subfolder)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /**
     * Creates a subfolder in the specified directory.  Does nothing if it already exists.
     */
    @discardableResult public static func create(subfolder: Folder, in directory: Directory) throws -> URL {
        let url = directory.baseUrl.appendingPathComponent(subfolder, isDirectory: true)
        var isDirectory: ObjCBool = false
        
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
    
    // MARK - URL
    
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
