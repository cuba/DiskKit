//
//  DiskData.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-09.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation
import UIKit

public enum ImageEncodingError: Error {
    case failedToEncode
}

public enum ImageFileType {
    case png
    case jpg(compressionQuality: Double)
    
    var fileExtension: String {
        switch self {
        case .png: return "png"
        case .jpg: return "jpg"
        }
    }
    
    func data(from image: UIImage) -> Data? {
        switch self {
        case .png:
            return UIImagePNGRepresentation(image)
        case .jpg(let quality):
            return UIImageJPEGRepresentation(image, CGFloat(quality))
        }
    }
}

public extension UIImage {
    func encode(to type: ImageFileType) throws -> Data {
        guard let data = type.data(from: self) else {
            throw ImageEncodingError.failedToEncode
        }
        
        return data
    }
}

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
     * Encode the specified UIImage
     * @file: the image file to encode
     * @name: the name this file will be given in disk
     * @type: the file image type that will be saved in disk
     */
    public init(image: UIImage, name: String, type: ImageFileType) throws {
        self.init(data: try image.encode(to: type), name: name)
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
    
    /**
     * Decode the data to the specified DiskDecodable type
     * @Returns: decoded struct model(s) of data
     */
    public func image() -> UIImage? {
        return UIImage(data: data)
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
