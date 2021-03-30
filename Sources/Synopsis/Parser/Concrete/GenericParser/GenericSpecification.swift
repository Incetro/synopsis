//
//  GenericSpecification.swift
//  
//
//  Created by incetro on 3/29/21.
//

import Foundation

// MARK: - GenericSpecification

public struct GenericSpecification {

    // MARK: - Properties

    /// Generic name
    public let name: String

    /// Generic inherited types
    public let inheritedTypes: [String]

    // MARK: - Initializers

    public init(
        name: String,
        inheritedTypes: [String] = []
    ) {
        self.name = name
        self.inheritedTypes = inheritedTypes
    }

    // MARK: - Template

    /// Make a template property for later code generation
    /// - Parameters:
    ///   - name: generic name
    ///   - inheritedTypes: generic inherited types
    /// - Returns: a template property for later code generation
    public static func template(
        name: String,
        inheritedTypes: [String]
    ) -> GenericSpecification {
        GenericSpecification(
            name: name,
            inheritedTypes: inheritedTypes
        )
    }
}

// MARK: - Specification

extension GenericSpecification: Specification {

    public var verse: String {
        if !inheritedTypes.isEmpty {
            return "\(name): \(inheritedTypes.joined(separator: " & "))"
        } else {
            return name
        }
    }
}

// MARK: - Equatable

extension GenericSpecification: Equatable {

    public static func == (left: GenericSpecification, right: GenericSpecification) -> Bool {
        return true
    }
}

// MARK: - CustomDebugStringConvertible

extension GenericSpecification: CustomDebugStringConvertible {

    public var debugDescription: String {
        "GENERIC name = \(name)" + (inheritedTypes.isEmpty ? "" : "inheritedTypes = \(inheritedTypes)")
    }
}
