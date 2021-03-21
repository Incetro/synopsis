//
//  AccessibilitySpecification.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - AccessibilitySpecification

/// Access mode for Swift statements
public enum AccessibilitySpecification {

    // MARK: - Cases

    case `private`
    case `internal`
    case `public`
    case `open`

    // MARK: - Static

    /// Obtains accessibility level
    /// from a raw structure element
    /// - Parameter element: some structure element
    /// - Returns: result accessibility level
    static func deduce(
        forRawStructureElement element: Parameters
    ) -> AccessibilitySpecification {
        switch element.accessibility {
        case "source.lang.swift.accessibility.private":
            return .private
        case "source.lang.swift.accessibility.public":
            return .public
        case "source.lang.swift.accessibility.open":
            return .open
        default:
            return .internal
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension AccessibilitySpecification: CustomDebugStringConvertible {

    /// Debug string description
    public var debugDescription: String {
        switch self {
        case .private:
            return "ACCESSIBILITY: private"
        case .public:
            return "ACCESSIBILITY: public"
        case .open:
            return "ACCESSIBILITY: open"
        default:
            return "ACCESSIBILITY: internal"
        }
    }
}

// MARK: - Specification

extension AccessibilitySpecification: Specification {

    /// Write down own source code.
    public var verse: String {
        switch self {
        case .private:
            return "private"
        case .public:
            return "public"
        case .open:
            return "open"
        default:
            return ""
        }
    }
}
