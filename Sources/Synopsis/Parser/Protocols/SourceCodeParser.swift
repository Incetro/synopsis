//
//  SourceCodeParser.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - SourceCodeParser

public protocol SourceCodeParser {

    associatedtype Element: Specification
    associatedtype Source: SourceCode

    /// Parse the given source code files
    /// - Parameter source: some source code files
    func parse(source: [Source]) -> [Element]
}
