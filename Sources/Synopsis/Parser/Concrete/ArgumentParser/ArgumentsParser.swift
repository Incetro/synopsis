//
//  ArgumentsParser.swift
//  Synopsis
//
//  Created by incetro on 11/25/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - ArgumentParser

/// Method arguments' parser
public final class ArgumentsParser {

    // MARK: - Useful

    /// Parse arguments from some function's parsed declaration
    /// - Parameter declaration: some function's parsed declaration
    /// - Returns: arguments from some function's parsed declaration
    public func parse(functionParsedDeclaration declaration: String) -> [ArgumentSpecification] {
        let rawArguments = extractRawArguments(fromMethodDeclaration: declaration)
        return parse(rawArguments: rawArguments)
    }

    // MARK: - Private

    /// Parse arguments sequence from some method declaration
    /// - Parameter declaration: some method declaration
    /// - Returns: arguments sequence from some method declaration
    private func extractRawArguments(fromMethodDeclaration declaration: String) -> String {
        let openBraceIndex = findOpenBrace(inMethodDeclaration: declaration)
        let argumentsStart = declaration.index(after: openBraceIndex)
        let lex = LexemeString(declaration)
        for index in declaration.indices where ")" == declaration[index] && lex.inSourceCodeRange(index) {
            return String(declaration[argumentsStart..<index])
        }
        return declaration
    }

    /// Finc the opening brace (before arguments sequence)
    /// in some method declaration
    /// - Parameter declaration: some method declaration
    /// - Returns: the opening brace index
    private func findOpenBrace(inMethodDeclaration declaration: String) -> String.Index {
        let lex = LexemeString(declaration)
        for index in declaration.indices where "(" == declaration[index] && lex.inSourceCodeRange(index) {
            return index
        }
        return declaration.startIndex
    }

    /// Parse arguments from the given arguments sequence
    /// - Parameter arguments: some arguments sequence
    /// - Returns: arguments as [ArgumentSpecification] array
    private func parse(rawArguments arguments: String) -> [ArgumentSpecification] {
        if arguments.isEmpty { return [] }
        var rawArgumentsWithoutComments = ""
        var inlineComments: [String] = []
        let lex = LexemeString(arguments)
        for lexeme in lex.lexemes {
            if lexeme.isCommentKind() {
                inlineComments.append(String(arguments[lexeme.left...lexeme.right]).truncateInlineCommentOpening())
            } else {
                rawArgumentsWithoutComments += String(arguments[lexeme.left...lexeme.right])
            }
        }
        return parse(rawArgumentsWithoutComments: rawArgumentsWithoutComments, comments: inlineComments)
    }

    /// Parse arguments declaration without comment between arguments
    /// - Parameters:
    ///   - rawArgumentsWithoutComments: raw arguments declaration
    ///   - comments: parsed comments for each argument
    /// - Returns: arguments as [ArgumentSpecification] array
    private func parse(rawArgumentsWithoutComments: String, comments: [String]) -> [ArgumentSpecification] {
        var commentsIterator = comments.makeIterator()
        return rawArgumentsWithoutComments
            .replacingOccurrences(of: "\n", with: "")
            .components(separatedBy: ",")
            .map { parse(argumentLine: $0, comment: commentsIterator.next()) }
    }

    /// Parse the given argument line with some comment
    /// - Parameters:
    ///   - line: some argument line
    ///   - comment: some comment for this argument
    /// - Returns: ArgumentSpecification value
    private func parse(argumentLine line: String, comment: String?) -> ArgumentSpecification {

        let argumentName:         String
        let externalArgumentName: String

        let annotations = comment.map(AnnotationParser().parse) ?? []
        let argumentType = TypeParser().deduceType(fromDeclaration: line)
        let defaultValue = getDefaultValue(fromArgumentLineWithNoComments: line)

        let names: String
        if line.contains(":") {
            names = String(line.truncateAfter(word: ":", deleteWord: true).trimmingCharacters(in: .whitespaces))
        } else {
            /// Only for enum cases
            /// like ```case some(Int)```
            names = ""
        }

        externalArgumentName = String(names.firstWord())
        argumentName = names.contains(" ")
            ? String(names.truncateUntil(word: " ", deleteWord: true))
            : externalArgumentName

        return ArgumentSpecification(
            name: externalArgumentName,
            bodyName: argumentName,
            type: argumentType,
            defaultValue: defaultValue,
            annotations: annotations,
            declaration: nil,
            comment: comment
        )
    }

    /// Obtain default value for argument
    /// - Parameter line: argument line
    /// - Returns: default value for argument
    private func getDefaultValue(fromArgumentLineWithNoComments line: String) -> String? {
        guard let equalSignIndex = line.firstIndex(of: "=") else { return nil }
        return String(line[equalSignIndex...].dropFirst().trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
