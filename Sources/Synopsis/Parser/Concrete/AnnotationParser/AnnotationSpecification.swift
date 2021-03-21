//
//  AnnotationSpecification.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - AnnotationSpecification

/// Meta-information about classes, protocols, structures,
/// properties, methods and method arguments located in the nearby
/// documentation comments
public struct AnnotationSpecification {

    // MARK: - Properties

    /// Name of the annotation; doesn't include "@" symbol
    public let name: String

    /// Value of the annotation; optional, contains
    /// first word after annotation name, if any.
    ///
    /// Inline annotations may be divided by semicolon,
    /// which may go immediately after annotation name
    /// in case annotation doesn't have any value.
    public let value: String?

    /// Annotation declaration
    public let declaration: Declaration?

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - name: name of the annotation; doesn't include "@" symbol
    ///   - value: value of the annotation
    ///   - declaration: annotation declaration
    public init(
        name: String,
        value: String?,
        declaration: Declaration?
    ) {
        self.name        = name
        self.value       = value
        self.declaration = declaration
    }
}

// MARK: - Equatable

extension AnnotationSpecification: Equatable {

    public static func == (left: AnnotationSpecification, right: AnnotationSpecification) -> Bool {
        return left.name        == right.name
            && left.value       == right.value
            && left.declaration == right.declaration
    }
}

// MARK: - CustomDebugStringConvertible

extension AnnotationSpecification: CustomDebugStringConvertible {

    public var debugDescription: String {
        "ANNOTATION: name = \(name)" + (nil != value ? "; value = \(value.unwrap())" : "")
    }
}

// MARK: - Specification

extension AnnotationSpecification: Specification {

    /// Write down own source code.
    public var verse: String {
        "@\(name)" + (value.map { " \($0)" } ?? "")
    }
}

// MARK: - Sequence

extension Sequence where Iterator.Element == AnnotationSpecification {

    public subscript(annotationName: String) -> Iterator.Element? {
        first { $0.name == annotationName }
    }

    public func contains(annotationName: String) -> Bool {
        self[annotationName] != nil
    }
}
