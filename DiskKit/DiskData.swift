//
//  DiskData.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-09.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public struct DiskData {
    let fileName: String
    let data: Data
    
    init(data: Data, name: String) {
        self.fileName = name
        self.data = data
    }
    
    /**
     * Encode the given Encodable file
     * @file: the encodable struct to store
     */
    public init<T: Encodable>(file: T, name: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(file)
        self.init(data: data, name: name)
    }
    
    /**
     * Encode the specified DiskEncodable file
     * @file: the encodable struct to store
     */
    public init<T: DiskEncodable>(file: T, name: String) throws {
        let data = try file.encode()
        self.init(data: data, name: name)
    }
    
    /**
     * Decode the data to the specified Decodable type
     * @Returns: decoded struct model(s) of data
     */
    public func decode<T: Decodable>() throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    /**
     * Decode the data to the specified DiskDecodable type
     * @Returns: decoded struct model(s) of data
     */
    public func decode<T: DiskDecodable>() throws -> T {
        return try T(data)
    }
    
    public func makeFileWrapper() -> FileWrapper {
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.filename = fileName
        return fileWrapper
    }
}

extension DiskData: Equatable {
    public static func == (lhs: DiskData, rhs: DiskData) -> Bool {
        return lhs.fileName == rhs.fileName
    }
}
