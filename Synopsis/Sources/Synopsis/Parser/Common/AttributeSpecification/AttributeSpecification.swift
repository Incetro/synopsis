//
//  File.swift
//  
//
//  Created by incetro on 11/27/20.
//

import Foundation

// MARK: - AttributeSpecification

public enum AttributeSpecification: String {

    // MARK: - Cases

    /// `final` keyword key
    case final = "source.decl.attribute.final"

    /// `mutating` keyword key
    case mutating = "source.decl.attribute.mutating"

    /// `override` keyword key
    case override = "source.decl.attribute.override"

    /// `indirect` keyword key
    case indirect = "source.decl.attribute.indirect"
}

// MARK: - CustomDebugStringConvertible

extension AttributeSpecification: CustomDebugStringConvertible {

    /// Debug string description
    public var debugDescription: String {
        switch self {
        case .final:
            return "ATTRIBUTE: final"
        case .mutating:
            return "ATTRIBUTE: mutating"
        case .override:
            return "ATTRIBUTE: override"
        case .indirect:
            return "ATTRIBUTE: indirect"
        }
    }
}

// MARK: - Specification

extension AttributeSpecification: Specification {

    /// Write down own source code.
    public var verse: String {
        switch self {
        case .final:
            return "final"
        case .mutating:
            return "mutating"
        case .override:
            return "override"
        case .indirect:
            return "indirect"
        }
    }
}
