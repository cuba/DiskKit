//
//  Migration.swift
//  DiskKit
//
//  Created by Jacob Sikorski on 2018-09-22.
//  Copyright © 2018 Jacob Sikorski. All rights reserved.
//

import Foundation

public enum MigrationError: Error {
    case migrationFailed(cause: Error?)
}

public protocol Migration {
    var uniqueName: String { get }
    func migrate(completion: @escaping () -> Void)
}
