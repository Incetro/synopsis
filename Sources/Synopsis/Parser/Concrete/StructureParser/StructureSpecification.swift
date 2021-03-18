//
//  File.swift
//  
//
//  Created by incetro on 11/27/20.
//

import Foundation

// MARK: - StructureSpecification

public struct StructureSpecification: ExtensibleSpecification {

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

    /// Structure annotations are located
    /// inside the block comment above the structure declaration
    public let annotations: [AnnotationSpecification]

    /// Structure declaration line
    public let declaration: Declaration

    /// Access visibility
    public let accessibility: AccessibilitySpecification

    /// Some structure attributes
    public let attributes: [AttributeSpecification]

    /// Name of the structure
    public let name: String

    /// Inherited types
    public let inheritedTypes: [String]

    /// List of structure properties
    public let properties: [PropertySpecification]

    /// Class initializers
    public let initializers: [MethodSpecification]

    /// Structure methods
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
        self.name           = name
        self.inheritedTypes = inheritedTypes
        self.properties     = properties
        self.initializers   = methods.filter(\.isInitializer)
        self.methods        = methods.filter(\.isFunction)
        self.attributes     = attributes
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
    ) -> StructureSpecification {
        return StructureSpecification(
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

extension StructureSpecification {

    /// Write down own source code
    public var verse: String {

        let enums = self.enums.map(\.verse).joined(separator: "\n\n")
        let enumsStr = enums.isEmpty ? "" : "\n\n" + enums

        let structs = self.structs.map(\.verse).joined(separator: "\n\n")
        let structsStr = structs.isEmpty ? "" : "\n\n" + structs

        let classes = self.classes.map(\.verse).joined(separator: "\n\n")
        let classesStr = classes.isEmpty ? "" : "\n\n" + classes

        let protocols = self.protocols.map(\.verse).joined(separator: "\n\n")
        let protocolsStr = protocols.isEmpty ? "" : "\n\n" + protocols

        let structureMarkStr = "// MARK: - \(name)\n\n"
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

        return "\(structureMarkStr)\(commentStr)"
             + "\(accessibilityStr)struct \(name)\(inheritedTypesStr) "
             + "{\n\(enumsStr.indent)\(structsStr.indent)\(classesStr.indent)\(protocolsStr.indent)\(propertiesStr)\(initializersStr)\(methodsStr)}\n"
    }
}

// MARK: - CustomDebugStringConvertible

extension StructureSpecification {

    public var debugDescription: String {
        if inheritedTypes.isEmpty {
            return "STRUCT: name = \(name)"
        }
        return "STRUCT: name = \(name); inherited = \(inheritedTypes.joined(separator: ", "))"
    }
}

// MARK: - Hashable

extension StructureSpecification: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(verse)
    }
}
