//
//  Document.swift
//  Example
//
//  Created by Jacob Sikorski on 2018-09-08.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation
import DiskKit

struct Article: Codable {
    static let fileExtension = "json"
    
    var uuid: String = UUID().uuidString
    var dateCreated: Date
    var dateUpdated: Date
    var body: String
    
    var filename: String {
        return [uuid, Article.fileExtension].joined(separator: ".")
    }
    
    var displayFileName: String {
        var components: [String] = [filename]
        
        if isModified {
            components.append("(modified)")
        }
        
        return components.joined(separator: " ")
    }
    
    var isModified: Bool
    
    init(body: String) {
        let date = Date()
        self.dateCreated = date
        self.dateUpdated = date
        self.body = body
        isModified = true
    }
}

extension Article: Equatable {
    public static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
