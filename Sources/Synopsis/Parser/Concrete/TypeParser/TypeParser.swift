//
//  TypeParser.swift
//  Synopsis
//
//  Created by incetro on 11/25/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - TypeParser

final class TypeParser {

    // MARK: - Private

    /// Returns type specification from the given declaration
    ///
    /// Ex:
    ///
    /// ```let string: String``` ==> returns 'String'
    ///
    /// ```let object: Object```  ==> returns 'Object'
    ///
    /// ```let number: Int = 13```  ==> returns 'Int'
    ///
    /// - Parameter declaration: some variable/parameter declaration
    /// - Returns: type specification from the given declaration
    private func parseExplicitType(fromDeclaration declaration: String) -> TypeSpecification? {
        guard declaration.contains(":") else { return parse(rawType: declaration) }
        let declarationWithoutDefaultValue = declaration
            .truncateAfter(word: "=", deleteWord: true)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let typename = declarationWithoutDefaultValue
            .truncateUntilExist(word: ":")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return parse(rawType: typename)
    }

    /// Try to guess a type from the declaration
    /// - Parameter declaration: some declaration
    /// - Returns: a type from the declaration
    private func deduceType(fromDefaultValue declaration: String) -> TypeSpecification {
        guard declaration.contains("=") else { return .object(name: "") }
        let defaultValue = declaration
            .truncateUntilExist(word: "=")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return guessType(ofVariableValue: defaultValue)
    }

    /// Parse raw type line without any other garbage.
    /// - Parameter rawType: raw type value
    /// - Returns: TypeSpecification instance
    private func parse(rawType: String) -> TypeSpecification {

        // check type ends with ?
        if rawType.hasSuffix("?") {
            return .optional(
                wrapped: parse(rawType: String(rawType.dropLast()))
            )
        }

        if rawType.contains("<") && rawType.contains(">") {
            let name = rawType.truncateAfter(word: "<", deleteWord: true).trimmingCharacters(in: .whitespacesAndNewlines)
            let itemName = String(rawType.truncateUntilExist(word: "<").truncateAfter(word: ">", deleteWord: true))
            let itemType = self.parse(rawType: itemName)
            return .generic(name: name, constraints: [itemType])
        }

        if rawType.contains("[") && rawType.contains("]") {
            let collecitonItemTypeName = rawType
                .truncateUntilExist(word: "[")
                .truncateAfter(word: "]", deleteWord: true)
                .trimmingCharacters(in: .whitespaces)
            return self.parseCollectionItemType(collecitonItemTypeName)
        }

        if rawType == "Bool" {
            return .boolean
        }

        if rawType.contains("Int") {
            return .integer
        }

        if rawType == "Float" {
            return .floatingPoint
        }

        if rawType == "Double" {
            return .doublePrecision
        }

        if rawType == "Date" {
            return .date
        }

        if rawType == "Data" {
            return .data
        }

        if rawType == "String" {
            return .string
        }

        if rawType == "Void" {
            return .void
        }

        var objectTypeName = rawType.contains("inout ") ? rawType : String(rawType.firstWord())
        if objectTypeName.last == "?" {
            objectTypeName = String(objectTypeName.dropLast())
        }

        return .object(name: objectTypeName)
    }

    /// Recognize the type of the given value
    /// - Parameter value: some value
    /// - Returns: type of the given value
    private func guessType(ofVariableValue value: String) -> TypeSpecification {

        // collections are not supported yet
        if value.contains("[") {
            return .object(name: "")
        }

        // check value is text in quotes:
        // let abc = "abcd"
        if let _ = value.range(of: "^\"(.*)\"$", options: .regularExpression) {
            return .string
        }

        // check value is double:
        // let abc = 123.45
        if let _ = value.range(of: "^(\\d+)\\.(\\d+)$", options: .regularExpression) {
            return .doublePrecision
        }

        // check value is int:
        // let abc = 123
        if let _ = value.range(of: "^(\\d+)$", options: .regularExpression) {
            return .integer
        }

        // check value is bool
        // let abc = true
        if value.contains("true") || value.contains("false") {
            return .boolean
        }

        // check value contains object init statement:
        // let abc = Object(some: 123)
        if let _ = value.range(of: "^(\\w+)\\((.*)\\)$", options: .regularExpression) {
            let rawValueTypeName = String(value.truncateAfter(word: "(", deleteWord: true))
            return parse(rawType: rawValueTypeName)
        }

        return .object(name: "")
    }

    /// Recognize collection item type
    /// - Parameter collecitonItemTypeName: some collection item type name
    /// - Returns: collection item type
    private func parseCollectionItemType(_ collecitonItemTypeName: String) -> TypeSpecification {
        if collecitonItemTypeName.contains(":") {
            let keyTypeName = String(collecitonItemTypeName.truncateAfter(word: ":", deleteWord: true))
            let valueTypeName = String(collecitonItemTypeName.truncateUntilExist(word: ":"))
            return .map(key: self.parse(rawType: keyTypeName), value: self.parse(rawType: valueTypeName))
        } else {
            return .array(element: self.parse(rawType: collecitonItemTypeName))
        }
    }

    // MARK: - Parser

    /// Translates the given parameters to TypeSpecification value
    /// - Parameter rawDescription: some type params
    /// - Returns: TypeSpecification value
    public func parse(rawDescription: Parameters) -> TypeSpecification {
        let typename = rawDescription.typename
        let declaration = rawDescription.parsedDeclaration
        switch typename {
        // TODO: incorporate all possible rawDescription.typename values
        case "Bool":
            return .boolean
        case "Int":
            return .integer
        case "Float":
            return .floatingPoint
        case "Double":
            return .doublePrecision
        case "String":
            return .string
        case "Void":
            return .void
        default:
            return deduceType(fromDeclaration: declaration)
        }
    }

    /// Parse some function's return type
    /// - Parameters:
    ///   - functionTypename: function name
    ///   - declarationString: function declaration string
    /// - Returns: TypeSpecification value
    public func parse(
        functionTypename: String,
        declarationString: String
    ) -> TypeSpecification? {
        let errorTypeConstant = "<<error type>>"
        let containsErrorType = functionTypename.contains(errorTypeConstant)
        let returnTypename = containsErrorType
            ? String(declarationString.truncateUntil(word: "->", deleteWord: true))
                .replacingOccurrences(of: " ", with: "")
            : String(functionTypename.split(separator: " ").last.unwrap())
        switch returnTypename {
        case "()", "Void":
            return .void
        case "Bool":
            return .boolean
        case "Int":
            return .integer
        case "Float":
            return .floatingPoint
        case "Double":
            return .doublePrecision
        case "String":
            return .string
        default:
            if functionTypename != "<<error type>>" {
                return parse(rawType: returnTypename)
            }
            // FIXME: Make a LexemeString, exclude comments
            if !declarationString.contains("->") {
                return nil
            }
            if let rawReturnType = declarationString
                .components(separatedBy: "->")
                .last?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            {
                return parse(rawType: rawReturnType)
            }
            return nil
        }
    }

    /// Deduce type from the given declaration
    /// - Parameter declaration: some declaration
    /// - Returns: TypeSpecification value
    public func deduceType(fromDeclaration declaration: String) -> TypeSpecification {
        parseExplicitType(fromDeclaration: declaration) ?? deduceType(fromDefaultValue: declaration)
    }
}
