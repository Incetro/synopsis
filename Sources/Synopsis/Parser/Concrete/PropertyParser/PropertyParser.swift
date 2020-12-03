//
//  File.swift
//  
//
//  Created by incetro on 11/25/20.
//

import Foundation
import SourceKittenFramework

// MARK: - PropertyParser

final class PropertyParser {

    // MARK: - Private

    /// Check if the given property is an instance
    /// variable description
    /// - Parameter element: some property
    /// - Returns: true if the given property is an instance
    /// variable description
    private func isInstanceVariableDescription(_ element: Parameters) -> Bool {
        guard let kind = element.kind else { return false }
        return SwiftDeclarationKind.varInstance.rawValue == kind
            || SwiftDeclarationKind.varClass.rawValue    == kind
            || SwiftDeclarationKind.varStatic.rawValue   == kind
    }

    /// Obtain property's default value
    /// - Parameter parsedDeclaration: property code declaration string
    /// - Returns: property's default value
    private func getDefaultValue(fromParsedDeclaration parsedDeclaration: String) -> String? {
        let lex = LexemeString(parsedDeclaration)
        for index in parsedDeclaration.indices {
            if "=" == parsedDeclaration[index] && lex.inSourceCodeRange(index) {
                let defaultValueStart = parsedDeclaration.index(after: index)
                return parsedDeclaration[defaultValueStart...]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    /// Obtain property body from some property structure
    /// - Parameters:
    ///   - rawFunctionDescription: some property structure
    ///   - content: file content
    /// - Returns: property mody string (if exists)
    private func getBody(
        rawPropertyDescription: Parameters,
        withContent content: String
    ) -> String? {
        guard
            let bodyOffset = rawPropertyDescription.bodyOffset,
            let bodyLength = rawPropertyDescription.bodyLength
        else {
            return nil
        }
        let bodyStartIndex = content.index(content.startIndex, offsetBy: bodyOffset)
        let bodyEndIndex = content.index(bodyStartIndex, offsetBy: bodyLength)
        let body = String(content[bodyStartIndex..<bodyEndIndex])
            .components(separatedBy: "\n").dropLast()
            .joined(separator: "\n")
        return body
    }

    /// Get property type
    /// - Parameter rawPropertyDescription: property structure
    /// - Returns: property type
    private func getKind(rawPropertyDescription: Parameters) -> PropertySpecification.Kind {
        guard let kind = rawPropertyDescription.kind else {
            return .instance
        }
        switch kind {
        case SwiftDeclarationKind.varStatic.rawValue:
            return .static
        case SwiftDeclarationKind.varClass.rawValue:
            return .class
        default:
            return .instance
        }
    }

    // MARK: - Parser

    /// Parse the given structure to a property specification
    /// - Parameters:
    ///   - structure: dictionary with a property data
    ///   - fileURL: current file url
    ///   - content: current file content
    /// - Returns: parsed property specification
    public func parse(
        rawStructureElements: [Parameters],
        forFileAt fileURL: URL,
        withContent content: String
    ) -> [PropertySpecification] {
        rawStructureElements
            .filter(isInstanceVariableDescription)
            .map { (rawPropertyDescription: Parameters) -> PropertySpecification in
                let parsedDeclaration = rawPropertyDescription.parsedDeclaration
                let declarationOffset = rawPropertyDescription.offset
                let comment = rawPropertyDescription.comment
                let annotations = comment.map { AnnotationParser().parse(comment: $0) } ?? []
                let accessibility = AccessibilitySpecification.deduce(forRawStructureElement: rawPropertyDescription)
                let declarationKind = PropertySpecification.DeclarationKind.deduce(forPropertyDeclaration: parsedDeclaration)
                let name = rawPropertyDescription.name
                let type = TypeParser().parse(rawDescription: rawPropertyDescription)
                let defaultValue = getDefaultValue(fromParsedDeclaration: parsedDeclaration)
                let body = getBody(
                    rawPropertyDescription: rawPropertyDescription,
                    withContent: content
                )
                let kind = getKind(rawPropertyDescription: rawPropertyDescription)
                let declaration = Declaration(
                    filePath: fileURL,
                    fileContents: content,
                    rawText: parsedDeclaration,
                    offset: declarationOffset
                )
                return PropertySpecification(
                    comment: comment,
                    annotations: annotations,
                    accessibility: accessibility,
                    declarationKind: declarationKind,
                    name: name,
                    type: type,
                    defaultValue: defaultValue,
                    declaration: declaration,
                    kind: kind,
                    body: body
                )
            }
    }
}
