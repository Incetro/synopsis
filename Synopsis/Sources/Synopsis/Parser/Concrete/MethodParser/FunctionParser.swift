//
//  File.swift
//  
//
//  Created by incetro on 11/25/20.
//

import Foundation
import SourceKittenFramework

// MARK: - FunctionParser

public class FunctionParser<S: SourceCode, Function: FunctionSpecification> {

    // MARK: - Public

    /// Checks if the given structure is a function
    /// - Parameter element: some element structure
    /// - Returns: true if the given structure is a function
    public func isRawFunctionDescription(_ element: Parameters) -> Bool {
        SwiftDeclarationKind.functionFree.rawValue == element.kind
    }

    /// Parse the given structure to a function specification
    /// - Parameters:
    ///   - structure: dictionary with a function data
    ///   - fileURL: current file url
    ///   - content: current file content
    /// - Returns: parsed function specification
    public func parse(
        rawStructureElements: [Parameters],
        forFileAt fileURL: URL,
        withContent content: String
    ) -> [Function] {
        rawStructureElements
            .filter(isRawFunctionDescription)
            .map {
                parse(rawStructureElements: $0, forFileAt: fileURL, withContent: content)
            }
    }

    /// Parse the given structure to a function specification
    /// - Parameters:
    ///   - structure: dictionary with a function data
    ///   - fileURL: current file url
    ///   - content: current file content
    /// - Returns: parsed function specification
    public func parse(
        rawStructureElements: Parameters,
        forFileAt fileURL: URL,
        withContent content: String
    ) -> Function {

        let declarationOffset = rawStructureElements.offset
        let declarationString = deduceDeclaration(
            rawFunctionDescription: rawStructureElements,
            file: content,
            declarationOffset: declarationOffset
        )

        let name = rawStructureElements.name
        let comment = rawStructureElements.comment
        let annotations = comment.map { AnnotationParser().parse(comment: $0) } ?? []
        let accessibility = AccessibilitySpecification.deduce(forRawStructureElement: rawStructureElements)
        let attributes = rawStructureElements.attributes.compactMap(AttributeSpecification.init)
        let typename = rawStructureElements.typename
        let returnType = TypeParser().parse(functionTypename: typename, declarationString: declarationString)
        let kind = getKind(rawFunctionDescription: rawStructureElements)
        let body = getBody(rawFunctionDescription: rawStructureElements, withContent: content)
        let arguments = ArgumentParser().parse(functionParsedDeclaration: declarationString)

        let declaration = Declaration(
            filePath: fileURL,
            fileContents: content,
            rawText: declarationString,
            offset: declarationOffset
        )

        return Function(
            comment: comment,
            annotations: annotations,
            accessibility: accessibility,
            attributes: attributes,
            name: name,
            arguments: arguments,
            returnType: returnType,
            declaration: declaration,
            kind: kind,
            body: body
        )
    }

    /// Parse functions from the given source code
    /// - Parameter source: some source code representation
    /// - Returns: parsed functions
    private func parse(source: S) -> [Function] {
        source
            .substructure
            .filter(isRawFunctionDescription)
            .map {
                parse(
                    rawStructureElements: $0,
                    forFileAt: source.fileURL,
                    withContent: source.content
                )
            }
    }

    // MARK: - Private

    /// Sometimes SourceKit can't accurately parse full method declaration
    /// This constantly happens for multiline method declarations in protocols, where
    ///
    /// func abc(
    /// argument: Int
    /// ) -> String
    ///
    /// gets truncated to "func abc(".
    ///
    /// This is why defaultDeclarationString needs to be checked.
    private func deduceDeclaration(
        rawFunctionDescription: Parameters,
        file: String,
        declarationOffset: Int
    ) -> String {

        let defaultDeclarationString = rawFunctionDescription.parsedDeclaration
        let defaultDeclarationLex = LexemeString(defaultDeclarationString)

        /// Simple check searches for the right round bracket:
        for index in defaultDeclarationString.indices {
            if defaultDeclarationLex.inSourceCodeRange(index) && ")" == defaultDeclarationString[index] {
                return defaultDeclarationString
            }
        }
        /// defaultDeclarationString is enough for most cases.

        /// If defaultDeclarationString is not enough, full method declaration needs to be parsed manually
        let startIndex = file.index(file.startIndex, offsetBy: declarationOffset)
        let endIndex = file.index(startIndex, offsetBy: rawFunctionDescription.length)
        let fullText = String(file[startIndex...endIndex])
        let fullTextLex = LexemeString(fullText)

        var declarationString: String = ""
        for index in fullText.indices {
            /// Detect the end of method signature by the opening curly brace:
            if fullTextLex.inSourceCodeRange(index) && "{" == fullText[index] { break }
            declarationString.append(fullText[index])
        }

        return declarationString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    /// Get function kind
    /// - Parameter rawFunctionDescription: function structure
    /// - Returns: function kind
    private func getKind(rawFunctionDescription: Parameters) -> Function.Kind {
        guard let kind = rawFunctionDescription.kind else { return Function.Kind.free }
        switch kind {
        case SwiftDeclarationKind.functionMethodInstance.rawValue:
            return .instance
        case SwiftDeclarationKind.functionMethodClass.rawValue:
            return .class
        case SwiftDeclarationKind.functionMethodStatic.rawValue:
            return .static
        default:
            return .free
        }
    }

    /// Obtain method body from some function structure
    /// - Parameters:
    ///   - rawFunctionDescription: some function structure
    ///   - content: file content
    /// - Returns: method mody string (if exists)
    private func getBody(
        rawFunctionDescription: Parameters,
        withContent content: String
    ) -> String? {
        guard
            let bodyOffset = rawFunctionDescription.bodyOffset,
            let bodyLength = rawFunctionDescription.bodyLength
        else {
            return nil
        }
        let bodyStartIndex = content.index(content.startIndex, offsetBy: bodyOffset)
        let bodyEndIndex = content.index(bodyStartIndex, offsetBy: bodyLength)
        return String(content[bodyStartIndex..<bodyEndIndex])
    }
}

// MARK: - SourceCodeParser

extension FunctionParser: SourceCodeParser {

    public func parse(source: [S]) -> [Function] {
        source.flatMap(parse)
    }
}
