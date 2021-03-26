//
//  Declaration.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Files
import Foundation

// MARK: - Declaration

/// Source code element declaration.
/// Includes absolute file path, line number,
/// column number, offset and raw declaration text itself.
public struct Declaration {

    // MARK: - Properties

    /// File, where statement is declared
    public let filePath: URL

    /// Parsed condensed declaration
    public let rawText: String?

    /// How many characters to skip
    public let offset: Int

    /// Calculated line number
    public let lineNumber: Int

    /// Calculated column number
    public let columnNumber: Int

    /// Target file content
    public var content: String {
        let content = try? File(path: filePath.absoluteString).readAsString()
        return content ?? ""
    }

    /// All declared imports inside current file
    public var imports: [String] {
        content
            .components(separatedBy: "\n")
            .filter { $0.hasPrefix("import") }
            .compactMap { $0.components(separatedBy: " ").last }
    }

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - filePath: file, where statement is declared
    ///   - rawText: parsed condensed declaration
    ///   - offset: how many characters to skip
    ///   - lineNumber: calculated line number
    ///   - columnNumber: calculated column number
    public init(
        filePath: URL,
        rawText: String?,
        offset: Int,
        lineNumber: Int,
        columnNumber: Int
    ) {
        self.filePath = filePath
        self.rawText = rawText
        self.offset = offset
        self.lineNumber = lineNumber
        self.columnNumber = columnNumber
    }

    /// File content initializer
    /// - Parameters:
    ///   - filePath: file, where statement is declared
    ///   - fileContents: content in the given file
    ///   - rawText: parsed condensed declaration
    ///   - offset: how many characters to skip
    public init(
        filePath: URL,
        fileContents: String,
        rawText: String?,
        offset: Int
    ) {
        let offsetIndex = fileContents.index(fileContents.startIndex, offsetBy: offset)
        let textBeforeDeclaration = fileContents[..<offsetIndex]
        let textBeforeDeclarationLines = textBeforeDeclaration.components(separatedBy: "\n")
        let lineNumber = textBeforeDeclarationLines.count
        let columnNumber = (textBeforeDeclarationLines.last?.count ?? 0) + 1
        self.init(
            filePath: filePath,
            rawText: rawText,
            offset: offset,
            lineNumber: lineNumber,
            columnNumber: columnNumber
        )
    }

    /// File content initializer
    /// - Parameters:
    ///   - filePath: file, where statement is declared
    ///   - rawText: content in the given file
    ///   - offset: how many characters to skip
    /// - Throws: initializing error
    public init?(
        filePath: URL,
        rawText: String?,
        offset: Int
    ) throws {
        let fileContents = try String(contentsOf: filePath)
        self.init(
            filePath: filePath,
            fileContents: fileContents,
            rawText: rawText,
            offset: offset
        )
    }

    // MARK: - Mock

    public static let mock = Declaration(
        filePath: URL(fileURLWithPath: Declaration.MockProperties.filePath),
        rawText: Declaration.MockProperties.rawText,
        offset: Declaration.MockProperties.offset,
        lineNumber: Declaration.MockProperties.lineNumber,
        columnNumber: Declaration.MockProperties.columnNumber
    )

    // MARK: - MockProperties

    private enum MockProperties {
        static let filePath     = ""
        static let rawText      = ""
        static let offset       = -1
        static let lineNumber   = -1
        static let columnNumber = -1
    }
}

// MARK: - Equatable

extension Declaration: Equatable {

    public static func == (left: Declaration, right: Declaration) -> Bool {
        return left.filePath        == right.filePath
            && left.rawText         == right.rawText
            && left.offset          == right.offset
            && left.lineNumber      == right.lineNumber
            && left.columnNumber    == right.columnNumber
    }
}
