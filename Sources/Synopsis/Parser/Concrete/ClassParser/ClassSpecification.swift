//
//  File.swift
//  
//
//  Created by incetro on 11/27/20.
//

import Foundation

// MARK: - ClassSpecification

public struct ClassSpecification: ExtensibleSpecification {

    // MARK: - Properties

    /// Documentation comment above the struct
    public let comment: String?

    /// Class annotations are located
    /// inside the block comment above the class declaration
    public let annotations: [AnnotationSpecification]

    /// Class declaration line
    public let declaration: Declaration

    /// Access visibility
    public let accessibility: AccessibilitySpecification

    /// Some class attributes
    /// (generally needed for compatibility
    /// between extensible heirs and most often
    /// uses for checking with `final` keyword)
    public let attributes: [AttributeSpecification]

    /// Name of the class
    public let name: String

    /// Inherited types
    public let inheritedTypes: [String]

    /// List of class properties
    public let properties: [PropertySpecification]

    /// Class initializers
    public let initializers: [MethodSpecification]

    /// Class methods
    public let methods: [MethodSpecification]

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - comment: documentation comment above the extensible
    ///   - annotations: annotations are located inside the comment
    ///   - declaration: declaration
    ///   - accessibility: access visibility
    ///   - name: name
    ///   - inheritedTypes: inherited types: parent class/classes, structures etc.
    ///   - properties: list of properties
    ///   - methods: list of methods
    public init(
        comment: String?,
        annotations: [AnnotationSpecification],
        declaration: Declaration,
        accessibility: AccessibilitySpecification,
        attributes: [AttributeSpecification],
        name: String,
        inheritedTypes: [String],
        properties: [PropertySpecification],
        methods: [MethodSpecification]
    ) {
        self.comment        = comment
        self.annotations    = annotations
        self.declaration    = declaration
        self.accessibility  = accessibility
        self.attributes     = attributes
        self.name           = name
        self.inheritedTypes = inheritedTypes
        self.properties     = properties
        self.initializers   = methods.filter(\.isInitializer)
        self.methods        = methods.filter(\.isFunction)
    }

    // MARK: - Template

    /// Make a template property for later code generation
    /// - Parameters:
    ///   - comment: documentation comment above the extensible
    ///   - accessibility: access visibility
    ///   - name: name
    ///   - inheritedTypes: inherited types: parent class/classes, structures etc.
    ///   - properties: list of properties
    ///   - methods: list of methods
    public static func template(
        comment: String?,
        accessibility: AccessibilitySpecification,
        attributes: [AttributeSpecification],
        name: String,
        inheritedTypes: [String],
        properties: [PropertySpecification],
        methods: [MethodSpecification]
    ) -> ClassSpecification {
        return ClassSpecification(
            comment: comment,
            annotations: [],
            declaration: Declaration.mock,
            accessibility: accessibility,
            attributes: attributes,
            name: name,
            inheritedTypes: inheritedTypes,
            properties: properties,
            methods: methods
        )
    }
}

// MARK: - Specification

extension ClassSpecification {

    /// Write down own source code
    public var verse: String {

        let classMarkStr = "// MARK: - \(name)\n\n"
        let propertiesMarkStr = properties.isEmpty ? "" : "\n// MARK: - Properties\n".indent
        let methodsMarkStr = methods.isEmpty ? "" : "\n// MARK: - Useful\n".indent
        let initializersMarkStr = methods.isEmpty ? "" : "\n// MARK: - Initializers\n".indent

        let commentStr: String
        if let commentExpl = comment, !commentExpl.isEmpty {
            commentStr = commentExpl.prefixEachLine(with: "/// ") + "\n"
        } else {
            commentStr = ""
        }

        let accessibilityStr = accessibility.verse.isEmpty ? "" : "\(accessibility.verse) "
        let inheritedTypesStr = inheritedTypes.isEmpty ? "" : ": " + inheritedTypes.joined(separator: ", ")

        let propertiesStr = properties.isEmpty
            ? ""
            : properties.reduce(propertiesMarkStr + "\n") { result, property in
                result + property.verse.indent + (properties.last == property ? "\n" : "\n\n")
            }

        let initializersStr = initializers.isEmpty
            ? ""
            : initializers.reduce(initializersMarkStr + "\n") { result, initializer in
                result + initializer.verse.indent + (initializers.last == initializer ? "\n" : "\n\n")
            }

        let methodsStr = methods.isEmpty
            ? ""
            : methods.reduce(methodsMarkStr + "\n") { result, method in
                result + method.verse.indent + (methods.last == method ? "\n" : "\n\n")
            }

        let isFinal = attributes.contains(.final)
        let classStr = (isFinal ? "final " : "") + "class "

        return "\(classMarkStr)\(commentStr)"
            + "\(accessibilityStr)\(classStr)\(name)\(inheritedTypesStr)"
            + " {\n\(propertiesStr)\(initializersStr)\(methodsStr)}\n"
    }
}

// MARK: - CustomDebugStringConvertible

extension ClassSpecification {

    public var debugDescription: String {
        if inheritedTypes.isEmpty {
            return "CLASS: name = \(name)"
        }
        return """
        CLASS: name = \(name); inherited = \(inheritedTypes.joined(separator: ", "))

        properties:
        \(properties.compactMap { $0.declaration.rawText }.joined(separator: "\n"))
        \(properties.map(\.debugDescription).joined(separator: "\n"))

        initializers:
        \(initializers.compactMap { $0.declaration.rawText }.joined(separator: "\n"))
        \(initializers.map(\.debugDescription).joined(separator: "\n"))

        methods:
        \(methods.compactMap { $0.declaration.rawText }.joined(separator: "\n"))
        \(methods.map(\.debugDescription).joined(separator: "\n"))
        """
    }
}

// MARK: - Hashable

extension ClassSpecification: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(verse)
    }
}
