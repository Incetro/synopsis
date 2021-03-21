//
//  SynopsisError.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - SynopsisError

// Synopsis library makes a lot of work with files.
// This means I/O errors and content parsing errors.
// Thus, this structure was created.
public struct SynopsisError {

    // MARK: - Properties

    /// Error description
    public let description: String

    /// Error location
    public let file: URL

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - description: error description
    ///   - file: error location
    public init(description: String, file: URL) {
        self.description = description
        self.file = file
    }
}
