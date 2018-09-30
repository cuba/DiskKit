//
//  Document.swift
//  Example
//
//  Created by Jacob Sikorski on 2018-09-08.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation
import DiskKit

struct Article: Packagable {
    static let typeIdentifier: String = "com.jacobsikorski.diskkit.example.package"
    static let baseUrl = Disk.Directory.documents.makeUrl()
    
    var details: ArticleDetails
    var author: Author
    
    init() {
        self.details = ArticleDetails(body: "")
        self.author = Author(name: "John Doe")
    }
    
    init(package: Package) throws {
        details = try package.file("article.json")
        author = try package.file("author.json")
    }
    
    func fill(package: Package) throws {
        try package.add(details, name: "article.json")
        try package.add(author, name: "author.json")
    }
    
    func save(to url: URL, from originalUrl: URL?) throws {
        try PackagableDisk.store(self, to: url, originalUrl: originalUrl)
    }
    
    static func load(from url: URL) throws -> Article? {
        return try PackagableDisk.packagable(at: url)
    }
    
    static func loadAll(from url: URL) throws -> [Article] {
        return try PackagableDisk.packagables(in: url)
    }
}

struct ArticleDetails: Codable {
    
    var dateCreated: Date
    var dateUpdated: Date
    var body: String
    
    init(body: String) {
        let date = Date()
        self.dateCreated = date
        self.dateUpdated = date
        self.body = body
    }
}

struct Author: Codable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
