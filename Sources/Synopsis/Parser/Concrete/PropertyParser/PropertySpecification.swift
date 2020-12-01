//
//  File.swift
//  
//
//  Created by incetro on 11/25/20.
//

import Foundation

// MARK: - PropertySpecification

/// Property description.
public struct PropertySpecification {

    // MARK: - Properties

    /// Documentation comment
    public let comment: String?

    /// Property annotations
    public let annotations: [AnnotationSpecification]

    /// Access visibility
    public let accessibility: AccessibilitySpecification

    /// True if property is `let`
    /// Otherwise (if `var`) true
    public let constant: Bool

    /// Property name
    public let name: String

    /// Property type
    public let type: TypeSpecification

    /// Raw default value
    public let defaultValue: String?

    /// Property declaration line
    public let declaration: Declaration

    /// Kind of a property
    public let kind: Kind

    /// Getters, setters, didSetters, willSetters etc.
    public let body: String?

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - comment: documentation comment
    ///   - annotations: property annotations
    ///   - accessibility: access visibility
    ///   - constant: let / ver checking value
    ///   - name: property name
    ///   - type: property type
    ///   - defaultValue: raw default value
    ///   - declaration: property declaration line
    ///   - kind: kind of a property
    ///   - body: getters, setters, didSetters, willSetters etc.
    public init(
        comment: String?,
        annotations: [AnnotationSpecification],
        accessibility: AccessibilitySpecification,
        constant: Bool,
        name: String,
        type: TypeSpecification,
        defaultValue: String?,
        declaration: Declaration,
        kind: Kind,
        body: String?
    ) {
        self.comment       = comment
        self.annotations   = annotations
        self.accessibility = accessibility
        self.constant      = constant
        self.name          = name
        self.type          = type
        self.defaultValue  = defaultValue
        self.declaration   = declaration
        self.kind          = kind
        self.body          = body
    }

    // MARK: - Template

    /// Make a template property for later code generation.
    /// - Parameters:
    ///   - comment: documentation comment
    ///   - accessibility: access visibility
    ///   - constant: let / ver checking value
    ///   - name: property name
    ///   - type: property type
    ///   - defaultValue: raw default value
    ///   - kind: kind of a property
    ///   - body: getters, setters, didSetters, willSetters etc.
    public static func template(
        comment: String?,
        accessibility: AccessibilitySpecification,
        constant: Bool,
        name: String,
        type: TypeSpecification,
        defaultValue: String?,
        kind: Kind,
        body: String?
    ) -> PropertySpecification {
        PropertySpecification(
            comment: comment,
            annotations: [],
            accessibility: accessibility,
            constant: constant,
            name: name,
            type: type,
            defaultValue: defaultValue,
            declaration: Declaration.mock,
            kind: kind,
            body: body
        )
    }

    // MARK: - Kind

    public enum Kind {

        case `class`
        case `static`
        case instance

        public var verse: String {
            switch self {
            case .class:
                return "class"
            case .static:
                return "static"
            case .instance:
                return ""
            }
        }

        /// TODO: support global, local & parameter kinds
    }
}

// MARK: - Sequence

extension Sequence where Iterator.Element == PropertySpecification {

    public subscript(propertyName: String) -> Iterator.Element? {
        first { $0.name == propertyName }
    }

    public func contains(propertyName: String) -> Bool {
        nil != self[propertyName]
    }
}

// MARK: - Equatable

extension PropertySpecification: Equatable {

    public static func == (left: PropertySpecification, right: PropertySpecification) -> Bool {
        return left.comment         == right.comment
            && left.annotations     == right.annotations
            && left.accessibility   == right.accessibility
            && left.constant        == right.constant
            && left.name            == right.name
            && left.type            == right.type
            && left.defaultValue    == right.defaultValue
            && left.declaration     == right.declaration
            && left.kind            == right.kind
            && left.body            == right.body
    }
}

// MARK: - CustomDebugStringConvertible

extension PropertySpecification: CustomDebugStringConvertible {

    public var debugDescription: String {
        "PROPERTY: name = \(name); type = \(type); constant = \(constant)"
    }
}

// MARK: - Specification

extension PropertySpecification: Specification {

    /// Write down own source code.
    public var verse: String {

        let commentStr: String
        if let commentExpl = comment, !commentExpl.isEmpty {
            commentStr = commentExpl.prefixEachLine(with: "/// ") + "\n"
        } else {
            commentStr = ""
        }

        let accessibilityStr = accessibility.verse.isEmpty ? "" : "\(accessibility.verse) "
        let kindStr          = kind.verse.isEmpty ? "" : "\(kind.verse) "
        let constantStr      = constant ? "let" : "var"
        let bodyStr          = body.map { " {\n\($0.unindent)\n}" } ?? ""
        let defaultValueStr  = defaultValue.map { " = \($0)" } ?? ""

        return """
        \(commentStr)\(accessibilityStr)\(kindStr)\(constantStr) \(name): \(type.verse)\(defaultValueStr)\(bodyStr)
        """
    }
}