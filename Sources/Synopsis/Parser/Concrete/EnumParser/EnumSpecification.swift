//
//  EnumSpecification.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - EnumSpecification

public struct EnumSpecification {

    // MARK: - Properties

    /// Nested enums
    public let enums: [EnumSpecification]

    /// Nested structs
    public let structs: [StructureSpecification]

    /// Nested classes
    public let classes: [ClassSpecification]

    /// Nested protocols
    public let protocols: [ProtocolSpecification]

    /// Enum comment value
    public let comment: String?

    /// Enum annotations which are located inside
    /// the block comment above the enum declaration.
    public let annotations: [AnnotationSpecification]

    /// Enum declaration line
    public let declaration: Declaration

    /// Access visibility
    public let accessibility: AccessibilitySpecification

    /// Method attributes (like `indirect` etc.)
    public let attributes: [AttributeSpecification]

    /// Enum name
    public let name: String

    /// Inherited protocols, classes, structs etc.
    public let inheritedTypes: [String]

    /// Cases
    public let cases: [EnumCaseSpecification]

    /// List of enum properties.
    public let properties: [PropertySpecification]

    /// Enum methods
    public let methods: [MethodSpecification]

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - comment: enum comment value
    ///   - annotations: enum annotations
    ///   - declaration: enum declaration line
    ///   - accessibility: access visibility
    ///   - name: enum name
    ///   - inheritedTypes: inherited protocols, classes, structs etc.
    ///   - cases: cases
    ///   - properties: list of enum properties
    ///   - methods: enum methods
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
        cases: [EnumCaseSpecification],
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
        self.cases          = cases
        self.properties     = properties
        self.methods        = methods
    }

    // MARK: - Template

    /// Make a template enum for later code generation.
    public static func template(
        comment: String?,
        accessibility: AccessibilitySpecification,
        attributes: [AttributeSpecification],
        name: String,
        inheritedTypes: [String],
        cases: [EnumCaseSpecification],
        properties: [PropertySpecification],
        methods: [MethodSpecification]
    ) -> EnumSpecification {
        return EnumSpecification(
            comment: comment,
            annotations: [],
            declaration: Declaration.mock,
            accessibility: accessibility,
            attributes: attributes,
            name: name,
            inheritedTypes: inheritedTypes,
            cases: cases,
            properties: properties,
            methods: methods
        )
    }
}

// MARK: - Specification

extension EnumSpecification: Specification {

    public var verse: String {

        let enums = self.enums.map(\.verse).joined(separator: "\n\n")
        let enumsStr = enums.isEmpty ? "" : "\n\n" + enums

        let structs = self.structs.map(\.verse).joined(separator: "\n\n")
        let structsStr = structs.isEmpty ? "" : "\n\n" + structs

        let classes = self.classes.map(\.verse).joined(separator: "\n\n")
        let classesStr = classes.isEmpty ? "" : "\n\n" + classes

        let protocols = self.protocols.map(\.verse).joined(separator: "\n\n")
        let protocolsStr = protocols.isEmpty ? "" : "\n\n" + protocols

        let enumMarkStr = "// MARK: - \(name)\n\n"
        let casesMarkStr = "\n\n// MARK: - Cases".indent
        let propertiesMarkStr = properties.isEmpty ? "" : "\n// MARK: - Properties\n".indent
        let methodsMarkStr = methods.isEmpty ? "" : "\n// MARK: - Useful\n".indent

        let commentStr: String
        if let commentExpl = comment, !commentExpl.isEmpty {
            commentStr = commentExpl.prefixEachLine(with: "/// ") + "\n"
        } else {
            commentStr = ""
        }

        let accessibilityStr  = accessibility.verse.isEmpty ? "" : "\(accessibility.verse) "
        let attributesStr     = attributes.filter { [.indirect].contains($0) }.map(\.verse).joined(separator: " ")
        let inheritedTypesStr = inheritedTypes.isEmpty ? "" : ": " + inheritedTypes.joined(separator: ", ")
        let enumStr           = (attributesStr.isEmpty ? "" : " ") + "enum "

        let casesStr: String
        if cases.isEmpty {
            casesStr = ""
        } else {
            casesStr = cases.reduce("\n") { (result, enumCase) in
                if cases.first == enumCase {
                    return (enumCase.comment == nil ? "\n\n" : "\n") + enumCase.verse.indent + "\n"
                }
                return result + enumCase.verse.indent + "\n"
            }
        }

        let propertiesStr: String
        if properties.isEmpty {
            propertiesStr = ""
        } else {
            propertiesStr = properties.reduce("\n") { (result, property) in
                if properties.last == property {
                    return result + property.verse.indent + "\n"
                }
                return result + property.verse.indent + "\n\n"
            }
        }

        let methodsStr: String
        if methods.isEmpty {
            methodsStr = "\n"
        } else {
            methodsStr = methods.reduce("\n") { (result: String, method: MethodSpecification) -> String in
                methods.last == method
                    ? result + method.verse.indent + "\n"
                    : result + method.verse.indent + "\n\n"
            }
        }

        return "\(enumMarkStr)\(commentStr)"
             + "\(accessibilityStr)\(attributesStr)\(enumStr)\(name)\(inheritedTypesStr) "
            + "{\(enumsStr.indent)\(structsStr.indent)\(classesStr.indent)\(protocolsStr.indent)\(casesMarkStr)\(casesStr)"
             + "\(propertiesMarkStr)\(propertiesStr)"
             + "\(methodsMarkStr)\(methodsStr)}"
    }
}

// MARK: - Hashable

extension EnumSpecification: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(verse)
    }
}
