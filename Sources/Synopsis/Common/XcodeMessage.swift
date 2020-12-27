//
//  File.swift
//  
//
//  Created by incetro on 12/9/20.
//

import Foundation

// MARK: - XcodeMessage

/// Error, warning or note.
///
/// `XcodeMessage` instance is designed to be printed via `print()` method such that IDE will receieve this input
/// and display errors and warnings inside of the source code editor as actual errors and warnings.
public struct XcodeMessage: Error {

    /// Red errors, yellow warnings and "invisible" notes.
    public enum MessageType: String {
        case error      = "error"
        case warning    = "warning"
        case note       = "note"
    }

    /// Source code file URL
    public let file: URL

    /// Line number, where error/warning/note occured
    public let lineNumber: Int

    /// Column, where error/warning/note occured
    private let columnNumber: Int

    /// Message to be displayed
    public let message: String

    /// Error, warning or note
    public let type: MessageType

    /// Default initializer
    /// - Parameters:
    ///   - file: source code file URL
    ///   - lineNumber: line number, where error/warning/note occured
    ///   - columnNumber: column, where error/warning/note occured
    ///   - message: message to be displayed
    ///   - type: error, warning or note
    public init(
        file: URL,
        lineNumber: Int,
        columnNumber: Int,
        message: String,
        type: MessageType
    ) {
        self.file           = file
        self.lineNumber     = lineNumber
        self.columnNumber   = columnNumber
        self.message        = message
        self.type           = type
    }

    /// `Declaration` initializer
    /// - Parameters:
    ///   - declaration: target declaration instance
    ///   - message: message to be displayed
    ///   - type: error, warning or note
    public init(
        declaration: Declaration,
        message: String,
        type: MessageType = .error
    ) {
        self.init(
            file: declaration.filePath,
            lineNumber: declaration.lineNumber,
            columnNumber: declaration.columnNumber,
            message: message,
            type: type
        )
    }
}

// MARK: - CustomDebugStringConvertible

extension XcodeMessage: CustomDebugStringConvertible {

    public var debugDescription: String {
        "\(self.file.path):\(self.lineNumber):\(self.columnNumber): \(self.type.rawValue): \(self.message)\n"
    }
}

// MARK: - Equatable

extension XcodeMessage: Equatable {

    public static func == (left: XcodeMessage, right: XcodeMessage) -> Bool {
        return left.file       == right.file
            && left.lineNumber == right.lineNumber
            && left.message    == right.message
            && left.type       == right.type
    }
}
