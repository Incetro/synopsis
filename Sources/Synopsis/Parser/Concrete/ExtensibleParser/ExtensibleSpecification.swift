//
//  File.swift
//  
//
//  Created by incetro on 11/27/20.
//

import Foundation

// MARK: - ExtensibleSpecification

/// Basically, protocols, structs and classes.
public protocol ExtensibleSpecification: Specification, Equatable, CustomDebugStringConvertible {

    // MARK: - Properties

    /// Documentation comment above the extensible
    var comment: String? { get }

    /// Annotations are located inside the comment
    var annotations: [AnnotationSpecification] { get }

    /// Declaration
    var declaration: Declaration { get }

    /// Access visibility
    var accessibility: AccessibilitySpecification { get }

    /// Some atrributes (like `final` keyword)
    var attributes: [AttributeSpecification] { get }

    /// Name
    var name: String { get }

    /// Inherited types: parent class/classes, protocols etc.
    var inheritedTypes: [String] { get }

    /// List of properties
    var properties: [PropertySpecification] { get }

    /// List of initializers
    var initializers: [MethodSpecification] { get }

    /// List of methods
    var methods: [MethodSpecification] { get }

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - comment: documentation comment above the extensible
    ///   - annotations: annotations are located inside the comment
    ///   - declaration: declaration
    ///   - accessibility: access visibility
    ///   - name: name
    ///   - inheritedTypes: inherited types: parent class/classes, protocols etc.
    ///   - properties: list of properties
    ///   - methods: list of methods
    init(
        comment: String?,
        annotations: [AnnotationSpecification],
        declaration: Declaration,
        accessibility: AccessibilitySpecification,
        attributes: [AttributeSpecification],
        name: String,
        inheritedTypes: [String],
        properties: [PropertySpecification],
        methods: [MethodSpecification]
    )
}

// MARK: - Equatable

public func == <E: ExtensibleSpecification>(left: E, right: E) -> Bool {
    return left.comment        == right.comment
        && left.annotations    == right.annotations
        && left.declaration    == right.declaration
        && left.accessibility  == right.accessibility
        && left.name           == right.name
        && left.inheritedTypes == right.inheritedTypes
        && left.properties     == right.properties
        && left.methods        == right.methods
}

// MARK: - Sequence

extension Sequence where Iterator.Element: ExtensibleSpecification {

    public subscript(name: String) -> Iterator.Element? {
        first { $0.name == name }
    }

    public func contains(name: String) -> Bool {
        nil != self[name]
    }
}
