//
//  SourceCode.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - SourceCode

/// Any swift source code file
public protocol SourceCode {

    /// Target file url
    var fileURL: URL { get }

    /// Target file content
    var content: String { get }

    /// A dictionary which describes your source code
    /// from file at `fileURL` which has been obtained from
    /// SourceKitten framework
    var sourceCodeDictionary: Parameters { get }

    /// Source code substructure representation
    var substructure: [Parameters] { get }
}
