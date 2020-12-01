//
//  File.swift
//  
//
//  Created by incetro on 11/24/20.
//

import Foundation

// MARK: - EnumCaseSpecification

public struct EnumCaseSpecification {

    // MARK: - Properties

    /// Documentation comment
    public let comment: String?

    /// Annotations
    public let annotations: [AnnotationSpecification]

    /// Case name
    public let name: String

    /// Enum case arguments
    public let arguments: [ArgumentSpecification]

    /// Raw default value
    public let defaultValue: String?

    /// Declaration line
    public let declaration: Declaration

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - comment: documentation comment
    ///   - annotations: annotations
    ///   - name: case name
    ///   - defaultValue: raw default value
    ///   - declaration: declaration line
    public init(
        comment: String?,
        annotations: [AnnotationSpecification],
        name: String,
        arguments: [ArgumentSpecification],
        defaultValue: String?,
        declaration: Declaration
    ) {
        self.comment      = comment
        self.annotations  = annotations
        self.name         = name
        self.arguments    = arguments
        self.defaultValue = defaultValue
        self.declaration  = declaration
    }

    // MARK: - Static

    /// Make a template enum case for later code generation
    /// - Parameters:
    ///   - comment: documentation comment
    ///   - name: case name
    ///   - defaultValue: raw default value
    /// - Returns: EnumCaseSpecification instance
    public static func template(
        comment: String?,
        name: String,
        arguments: [ArgumentSpecification],
        defaultValue: String?
    ) -> EnumCaseSpecification {
        EnumCaseSpecification(
            comment: comment,
            annotations: [],
            name: name,
            arguments: arguments,
            defaultValue: defaultValue,
            declaration: .mock
        )
    }
}

// MARK: - Specification

extension EnumCaseSpecification: Specification {

    /// Swift code representation
    public var verse: String {

        let commentStr: String
        if let commentExpl = comment, !commentExpl.isEmpty {
            commentStr = "\n" + commentExpl.prefixEachLine(with: "/// ") + "\n"
        } else {
            commentStr = ""
        }

        let defaultValueStr = defaultValue.map { " = \($0)" } ?? ""

        let argumentsStr: String
        if arguments.isEmpty {
            argumentsStr = ""
        } else {
            argumentsStr = arguments.reduce("(") { (result: String, argument: ArgumentSpecification) -> String in
                arguments.last == argument
                    ? result + argument.verse + ")"
                    : result + argument.verseWithComma + " "
            }
        }

        return """
        \(commentStr)case \(name)\(defaultValueStr)\(argumentsStr)
        """
    }
}

// MARK: - Equatable

extension EnumCaseSpecification: Equatable {

    public static func == (left: EnumCaseSpecification, right: EnumCaseSpecification) -> Bool {
        return left.comment      == right.comment
            && left.annotations  == right.annotations
            && left.name         == right.name
            && left.defaultValue == right.defaultValue
            && left.declaration  == right.declaration
    }
}

// MARK: - CustomDebugStringConvertible

extension EnumCaseSpecification: CustomDebugStringConvertible {

    public var debugDescription: String {
        "ENUMCASE: name = \(name)"
    }
}

// MARK: - Sequence

extension Sequence where Iterator.Element == EnumCaseSpecification {

    public subscript(name: String) -> Iterator.Element? {
        first { $0.name == name }
    }

    public func contains(name: String) -> Bool {
        nil != self[name]
    }
}
