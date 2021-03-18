//
//  File.swift
//  
//
//  Created by incetro on 11/28/20.
//

import Foundation

// MARK: - EtensionSpecification

public struct ExtensionSpecification: ExtensibleSpecification {

    // MARK: - Properties

    /// Nested enums
    public let enums: [EnumSpecification]

    /// Nested structs
    public let structs: [StructureSpecification]

    /// Nested classes
    public let classes: [ClassSpecification]

    /// Nested protocols
    public let protocols: [ProtocolSpecification]

    /// Documentation comment above the struct
    public let comment: String?

    /// Extension annotations are located
    /// inside the block comment above the extension declaration
    public let annotations: [AnnotationSpecification]

    /// Extension declaration line
    public let declaration: Declaration

    /// Access visibility
    public let accessibility: AccessibilitySpecification

    /// Some extension attributes
    /// (generally needed for compatibility
    /// between extensible heirs and most often
    /// uses for checking with `final` keyword)
    public let attributes: [AttributeSpecification]

    /// Name of the extension
    public let name: String

    /// Inherited types
    public let inheritedTypes: [String]

    /// List of extension properties
    public let properties: [PropertySpecification]

    /// Extension initializers
    public let initializers: [MethodSpecification]

    /// Extension methods
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
        enums: [EnumSpecification] = [],
        structs: [StructureSpecification] = [],
        classes: [ClassSpecification] = [],
        protocols: [ProtocolSpecification] = [],
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
        self.enums          = enums
        self.structs        = structs
        self.classes        = classes
        self.protocols      = protocols
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
    ///   - inheritedTypes: inherited protocols
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
    ) -> ExtensionSpecification {
        return ExtensionSpecification(
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

extension ExtensionSpecification {

    /// Write down own source code
    public var verse: String {

        let extensionMarkStr = "// MARK: - \(inheritedTypes.joined(separator: ", "))\n\n"

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
            : properties.reduce("\n") { result, property in
                result + property.verse.indent + (properties.last == property ? "\n" : "\n\n")
            }

        let initializersStr = initializers.isEmpty
            ? ""
            : initializers.reduce("\n") { result, initializer in
                result + initializer.verse.indent + (initializers.last == initializer ? "\n" : "\n\n")
            }

        let methodsStr = methods.isEmpty
            ? ""
            : methods.reduce("\n") { result, method in
                result + method.verse.indent + (methods.last == method ? "\n" : "\n\n")
            }

        return "\(extensionMarkStr)\(commentStr)"
            + "\(accessibilityStr)extension \(name)\(inheritedTypesStr)"
            + " {\n\(propertiesStr)\(initializersStr)\(methodsStr)}\n"
    }
}

// MARK: - CustomDebugStringConvertible

extension ExtensionSpecification {

    public var debugDescription: String {
        if inheritedTypes.isEmpty {
            return "EXTENSION: name = \(name)"
        }
        return """
        EXTENSION: name = \(name); inherited = \(inheritedTypes.joined(separator: ", "))

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
