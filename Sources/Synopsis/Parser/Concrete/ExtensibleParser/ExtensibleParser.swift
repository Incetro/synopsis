//
//  File.swift
//  
//
//  Created by incetro on 11/27/20.
//

import Foundation

// MARK: - ExtensibleParser

public class ExtensibleParser<S: SourceCode, Model: ExtensibleSpecification> {

    // MARK: - Useful

    /// Checks if the given structure is an extensible
    /// - Parameter element: some element structure
    /// - Returns: true if the given structure is an enum
    public func isRawExtensibleSpecification(_ element: Parameters) -> Bool {
        false
    }

    // MARK: - Private

    /// Parse enums from the given source code
    /// - Parameter source: some source code representation
    /// - Returns: parsed enums
    private func parse(source: S) -> [Model] {
        source
            .substructure
            .filter(isRawExtensibleSpecification)
            .map {
                parse(
                    extensibleDictionary: $0,
                    forFileAt: source.fileURL,
                    withContent: source.content
                )
            }
    }
}

// MARK: - Parser

extension ExtensibleParser {

    /// Parse the given structure to an enum specification
    /// - Parameters:
    ///   - structure: dictionary with an enum data
    ///   - fileURL: current file url
    ///   - content: current file content
    /// - Returns: parsed enum specification
    public func parse(
        extensibleDictionary: Parameters,
        forFileAt fileURL: URL,
        withContent content: String
    ) -> Model {

        let comment = extensibleDictionary.comment
        let annotations = comment.flatMap { AnnotationParser().parse(comment: $0) } ?? []
        let accessibility = AccessibilitySpecification.deduce(forRawStructureElement: extensibleDictionary)
        let attributes = extensibleDictionary.attributes.compactMap(AttributeSpecification.init)
        let name = extensibleDictionary.name
        let inheritedTypes = extensibleDictionary.inheritedTypes

        let properties = PropertyParser().parse(
            rawStructureElements: extensibleDictionary.subsctructure,
            forFileAt: fileURL,
            withContent: content
        )
        let methods = MethodParser<S>().parse(
            rawStructureElements: extensibleDictionary.subsctructure,
            forFileAt: fileURL,
            withContent: content
        )

        let declarationOffset = extensibleDictionary.offset

        let declaration = Declaration(
            filePath: fileURL,
            fileContents: content,
            rawText: extensibleDictionary.parsedDeclaration,
            offset: declarationOffset
        )

        return Model(
            comment: comment,
            annotations: annotations,
            declaration: declaration,
            accessibility: accessibility,
            attributes: attributes,
            name: name,
            inheritedTypes: inheritedTypes,
            properties: properties,
            methods: methods
        )
    }
}

// MARK: - SourceCodeParser

extension ExtensibleParser: SourceCodeParser {

    public func parse(source: [S]) -> [Model] {
        source.flatMap(parse)
    }
}
