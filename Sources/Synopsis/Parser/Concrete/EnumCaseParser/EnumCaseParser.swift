//
//  File.swift
//  
//
//  Created by incetro on 11/24/20.
//

import Foundation
import SourceKittenFramework

// MARK: - EnumCaseParser

public final class EnumCaseParser {

    // MARK: - EnumCaseElement

    /// Enum case element structure
    private struct EnumCaseElement {

        // MARK: - Properties

        /// Case offset
        let offset: Int

        /// Case structure
        let structure: Parameters
    }

    // MARK: - Private

    /// Checks if the given structure is an enum case
    /// - Parameter element: some element structure
    /// - Returns: true if the given structure is an enum case
    private func isRawEnumCaseDescription(_ element: Parameters) -> Bool {
        SwiftDeclarationKind.enumcase.rawValue == element.kind
    }

    /// Obtain default value for some `case`
    /// - Parameter parsedDeclaration: code declaration of some case
    ///
    /// Ex:
    ///
    /// ```case something = 256``` ==> default value = 256
    ///
    /// ```case something = "String"``` ==> default value = "String"
    ///
    /// - Returns: default value for some `case`
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
}

// MARK: - Parser

extension EnumCaseParser {

    /// Parse the given structure to
    /// enum cases specification
    /// - Parameters:
    ///   - structure: array with cases data
    ///   - fileURL: current file url
    ///   - content: current file content
    /// - Returns: enum cases specification
    public func parse(
        structure: [Parameters],
        forFileAt fileURL: URL,
        withContent content: String
    ) -> [EnumCaseSpecification] {
        structure
            .filter(isRawEnumCaseDescription)
            .flatMap { enumCaseDictionary in
                /// Each enum case may contain multiple options:
                ///
                /// enum MyEnum {
                ///    case option1, option2
                /// }
                /// Our goal is to flat them out
                enumCaseDictionary.subsctructure.map {
                    EnumCaseElement(offset: enumCaseDictionary.offset, structure: $0)
                }
            }
            .map { enumCaseElement in

                let parsedDeclaration = enumCaseElement.structure.parsedDeclaration
                let comment = enumCaseElement.structure.comment

                let annotations = comment.flatMap { AnnotationParser().parse(comment: $0) } ?? []
                let containsArguments = parsedDeclaration.contains("(")
                let name = containsArguments
                    ? parsedDeclaration
                        .truncateUntil(word: " ", deleteWord: true)
                        .truncateAfter(word: "(", deleteWord: true)
                        .trimmingCharacters(in: .whitespaces)
                    : enumCaseElement.structure.name
                let defaultValue = getDefaultValue(fromParsedDeclaration: parsedDeclaration)
                let arguments = containsArguments
                    ? ArgumentsParser().parse(functionParsedDeclaration: parsedDeclaration)
                    : []

                let declaration = Declaration(
                    filePath: fileURL,
                    fileContents: content,
                    rawText: parsedDeclaration,
                    offset: enumCaseElement.offset
                )

                return EnumCaseSpecification(
                    comment: comment,
                    annotations: annotations,
                    name: name,
                    arguments: arguments,
                    defaultValue: defaultValue,
                    declaration: declaration
                )
            }
    }
}
