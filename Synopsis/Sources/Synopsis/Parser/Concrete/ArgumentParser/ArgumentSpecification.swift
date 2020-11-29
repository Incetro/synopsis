//
//  File.swift
//  
//
//  Created by incetro on 11/25/20.
//

import Foundation

// MARK: - ArgumentSpecification

/// Method argument description
public struct ArgumentSpecification {

    // MARK: - Properties

    /// Argument "external" name used in method calls
    public let name: String

    /// Argument "internal" name used inside method body
    public let bodyName: String

    /// Argument type
    public let type: TypeSpecification

    /// Default value, if any
    public let defaultValue: String?

    /// Argument annotations;
    /// N.B.: arguments only have inline annotations
    public let annotations: [AnnotationSpecification]

    /// Argument declaration
    public let declaration: Declaration? // FIXME: Make mandatory

    /// Inline comment
    public let comment: String?

    /// Parameter string length with no comments
    var lengthWithoutComment: Int {
        verse.components(separatedBy: "///")[0].count
    }

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - name: argument "external" name used in method calls
    ///   - bodyName: argument "internal" name used inside method body
    ///   - type: argument type
    ///   - defaultValue: default value, if any
    ///   - annotations: argument annotations; N.B.: arguments only have inline annotations
    ///   - declaration: argument declaration
    ///   - comment: inline comment
    public init(
        name: String,
        bodyName: String,
        type: TypeSpecification,
        defaultValue: String?,
        annotations: [AnnotationSpecification],
        declaration: Declaration?,
        comment: String?
    ) {
        self.name         = name
        self.bodyName     = bodyName
        self.type         = type
        self.defaultValue = defaultValue
        self.annotations  = annotations
        self.declaration  = declaration
        self.comment      = comment
    }

    // MARK: - Template

    /// Make a template for later code generation.
    public static func template(
        name: String,
        bodyName: String,
        type: TypeSpecification,
        defaultValue: String?,
        comment: String?
    ) -> ArgumentSpecification {
        ArgumentSpecification(
            name: name,
            bodyName: bodyName,
            type: type,
            defaultValue: defaultValue,
            annotations: [],
            declaration: Declaration.mock,
            comment: comment
        )
    }
}

extension ArgumentSpecification: Specification {

    /// Write down own source code.
    public var verse: String {
        let defaultValueStr = defaultValue.map { " = \($0)" } ?? ""
        if name == bodyName {
            let nameStr = name.isEmpty ? "" : "\(name): "
            return "\(nameStr)\(type.verse)\(defaultValueStr)" + (nil != comment ? " ///\(comment.unwrap())" : "")
        } else {
            return "\(name) \(bodyName): \(type.verse)\(defaultValueStr)" + (nil != comment ? " ///\(comment.unwrap())" : "")
        }
    }

    /// Write down own source code
    /// like if it was one of multiple arguments
    public var verseWithComma: String {
        let defaultValueStr = defaultValue.map { " = \($0)" } ?? ""
        if name == bodyName {
            let nameStr = name.isEmpty ? "" : "\(name): "
            return "\(nameStr)\(type.verse)\(defaultValueStr)," + (nil != comment ? " ///\(comment.unwrap())" : "")
        } else {
            return "\(name) \(bodyName): \(type.verse)\(defaultValueStr)," + (nil != comment ? " ///\(comment.unwrap())" : "")
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension ArgumentSpecification: CustomDebugStringConvertible {

    public var debugDescription: String {
        "ARGUMENT: name = \(name); body name = \(bodyName); type = \(type)"
    }
}

// MARK: - Equatable

extension ArgumentSpecification: Equatable {

    public static func ==(left: ArgumentSpecification, right: ArgumentSpecification) -> Bool {
        return left.annotations  == right.annotations
            && left.name         == right.name
            && left.bodyName     == right.bodyName
            && left.type         == right.type
            && left.defaultValue == right.defaultValue
            && left.declaration  == right.declaration
            && left.comment      == right.comment
    }
}

// MARK: - Sequence

extension Sequence where Iterator.Element == ArgumentSpecification {

    public subscript(argumentName: String) -> Iterator.Element? {
        first { $0.name == argumentName }
    }

    public func contains(argumentName: String) -> Bool {
        nil != self[argumentName]
    }
}
