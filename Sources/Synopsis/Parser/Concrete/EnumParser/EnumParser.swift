//
//  File.swift
//  
//
//  Created by incetro on 11/23/20.
//

import Foundation
import SourceKittenFramework

// MARK: - EnumParser

public final class EnumParser<S: SourceCode> {

    // MARK: - Private

    /// Checks if the given structure is an enum
    /// - Parameter element: some element structure
    /// - Returns: true if the given structure is an enum
    private func isRawEnumDescription(_ element: Parameters) -> Bool {
        SwiftDeclarationKind.`enum`.rawValue == element.kind
    }

    /// Parse enums from the given source code
    /// - Parameter source: some source code representation
    /// - Returns: parsed enums
    private func parse(source: S) -> [EnumSpecification] {
        source
            .substructure
            .filter(isRawEnumDescription)
            .map {
                parse(
                    enumDictionary: $0,
                    forFileAt: source.fileURL,
                    withContent: source.content
                )
            }
    }
}

// MARK: - Parser

extension EnumParser {

    /// Parse the given structure to an enum specification
    /// - Parameters:
    ///   - structure: dictionary with an enum data
    ///   - fileURL: current file url
    ///   - content: current file content
    /// - Returns: parsed enum specification
    public func parse(
        enumDictionary: Parameters,
        forFileAt fileURL: URL,
        withContent content: String
    ) -> EnumSpecification {

        let comment = enumDictionary.comment
        let annotations = comment.flatMap { AnnotationParser().parse(comment: $0) } ?? []
        let accessibility = AccessibilitySpecification.deduce(forRawStructureElement: enumDictionary)
        let attributes = enumDictionary.attributes.compactMap(AttributeSpecification.init)
        let name = enumDictionary.name
        let inheritedTypes = enumDictionary.inheritedTypes
        let cases = EnumCaseParser().parse(
            structure: enumDictionary.subsctructure,
            forFileAt: fileURL,
            withContent: content
        )
        let properties = PropertyParser().parse(
            rawStructureElements: enumDictionary.subsctructure,
            forFileAt: fileURL,
            withContent: content
        )
        let methods = MethodParser<S>().parse(
            rawStructureElements: enumDictionary.subsctructure,
            forFileAt: fileURL,
            withContent: content
        )

        let declarationOffset = enumDictionary.offset

        let declaration = Declaration(
            filePath: fileURL,
            fileContents: content,
            rawText: enumDictionary.parsedDeclaration,
            offset: declarationOffset
        )

        return EnumSpecification(
            comment: comment,
            annotations: annotations,
            declaration: declaration,
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

// MARK: - SourceCodeParser

extension EnumParser: SourceCodeParser {

    public func parse(source: [S]) -> [EnumSpecification] {
        source.flatMap(parse)
    }
}
