//
//  File.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-09.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation
import UIKit

public enum FileEncodingError: Error {
    case failedToEncodeImage
    case failedToEncodeText
}

public enum ImageFileType {
    case png
    case jpg(compressionQuality: Double)
    
    var typeIdentifier: String {
        switch self {
        case .png: return "png"
        case .jpg: return "jpg"
        }
    }
    
    func data(from image: UIImage) -> Data? {
        switch self {
        case .png:
            return image.pngData()
        case .jpg(let quality):
            return image.jpegData(compressionQuality: CGFloat(quality))
        }
    }
}

public extension UIImage {
    func encode(to type: ImageFileType) throws -> Data {
        guard let data = type.data(from: self) else {
            throw FileEncodingError.failedToEncodeImage
        }
        
        return data
    }
}

public struct File {
    
    public let filename: String
    public let data: Data
    
    public init(data: Data, name: String) {
        self.filename = name
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
     * Encode the specified string
     * @text: the text to encode into a utf8 text file
     * @name: the name this file will be given in disk
     */
    public init(text: String, name: String, encoding: String.Encoding) throws {
        guard let data = text.data(using: encoding) else {
            throw FileEncodingError.failedToEncodeText
        }
        
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
    
    /**
     * Decode the data a UIImage
     * @Returns: decoded image
     */
    public func image() -> UIImage? {
        return UIImage(data: data)
    }
    
    /**
     * Decode the data a UIImage
     * @Returns: decoded image
     */
    public func text(encoding: String.Encoding) -> String? {
        return String(data: data, encoding: encoding)
    }
    
    public func makeFileWrapper() -> FileWrapper {
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.filename = filename
        return fileWrapper
    }
}

extension File: Equatable {
    public static func == (lhs: File, rhs: File) -> Bool {
        return lhs.filename == rhs.filename
    }
}
