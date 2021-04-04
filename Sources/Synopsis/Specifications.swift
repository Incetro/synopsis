//
//  Specifications.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - Specifications

public struct Specifications {

    // MARK: - Properties

    /// Enumerations specifications
    public let enums: [EnumSpecification]

    /// Protocols specifications
    public let protocols: [ProtocolSpecification]

    /// Structures specifications
    public let structures: [StructureSpecification]

    /// Classes specifications
    public let classes: [ClassSpecification]

    /// Functions specifications
    public let functions: [FunctionSpecification]

    /// Extensions specifications
    public let extensions: [ExtensionSpecification]

    // MARK: - Consolidation

    /// Enums which are consolidated with their extensions
    public var consolidatedEnums: [EnumSpecification: [ExtensionSpecification]] {
        var consolidated: [EnumSpecification: [ExtensionSpecification]] = [:]
        for `enum` in enums {
            consolidated[`enum`] = extensions.filter { $0.name == `enum`.name }
        }
        return consolidated
    }

    /// Protocols which are consolidated with their extensions
    public var consolidatedProtocols: [ProtocolSpecification: [ExtensionSpecification]] {
        var consolidated: [ProtocolSpecification: [ExtensionSpecification]] = [:]
        for `protocol` in protocols {
            consolidated[`protocol`] = extensions.filter { $0.name == `protocol`.name }
        }
        return consolidated
    }

    /// Structures which are consolidated with their extensions
    public var consolidatedStructures: [StructureSpecification: [ExtensionSpecification]] {
        var consolidated: [StructureSpecification: [ExtensionSpecification]] = [:]
        for structure in structures {
            consolidated[structure] = extensions.filter { $0.name == structure.name }
        }
        return consolidated
    }

    /// Classes which are consolidated with their extensions
    public var consolidatedClasses: [ClassSpecification: [ExtensionSpecification]] {
        var consolidated: [ClassSpecification: [ExtensionSpecification]] = [:]
        for `class` in classes {
            consolidated[`class`] = extensions.filter { $0.name == `class`.name }
        }
        return consolidated
    }
}

// MARK: - Xcode

public extension Specifications {

    func printToXcode() {
        let messages = [
            extensibleMessages(extensibles: classes),
            extensibleMessages(extensibles: structures),
            extensibleMessages(extensibles: protocols),
            extensibleMessages(extensibles: extensions)
        ].flatMap { $0 }
        messages.forEach { print($0) }
    }

    // MARK: - Private

    private func extensibleMessages<E: ExtensibleSpecification>(extensibles: [E]) -> [XcodeMessage] {
        var messages: [XcodeMessage] = []
        extensibles.forEach { (extensibleSpecification: E) in
            messages.append(
                XcodeMessage(
                    declaration: extensibleSpecification.declaration,
                    message: extensibleSpecification.debugDescription,
                    type: .warning
                )
            )
            extensibleSpecification.annotations.forEach { (annotation: AnnotationSpecification) in
                messages.append(
                    XcodeMessage(
                        /// TODO: replace with Annotation.declaration
                        declaration: extensibleSpecification.declaration,
                        message: annotation.debugDescription,
                        type: .warning
                    )
                )
            }
            extensibleSpecification.properties.forEach { (propertySpecification: PropertySpecification) in
                messages.append(
                    XcodeMessage(
                        declaration: propertySpecification.declaration,
                        message: propertySpecification.debugDescription,
                        type: .warning
                    )
                )
            }
            extensibleSpecification.methods.forEach { (methodSpecification: MethodSpecification) in
                messages.append(
                    XcodeMessage(
                        declaration: methodSpecification.declaration,
                        message: methodSpecification.debugDescription,
                        type: .warning
                    )
                )
                methodSpecification.arguments.forEach { (argumentSpecification: ArgumentSpecification) in
                    messages.append(
                        XcodeMessage(
                            /// TODO: replace with ArgumentSpecification.declaration
                            declaration: methodSpecification.declaration,
                            message: argumentSpecification.debugDescription,
                            type: .warning
                        )
                    )
                }
            }
        }
        return messages
    }
}

// MARK: - Array

public extension Array where Element == StructureSpecification {

    func named(_ name: String) -> StructureSpecification? {
        first { $0.name == name }
    }
}

public extension Array where Element == ClassSpecification {

    func named(_ name: String) -> ClassSpecification? {
        first { $0.name == name }
    }
}

public extension Array where Element == EnumSpecification {

    func named(_ name: String) -> EnumSpecification? {
        first { $0.name == name }
    }
}

public extension Array where Element == ProtocolSpecification {

    func named(_ name: String) -> ProtocolSpecification? {
        first { $0.name == name }
    }
}
