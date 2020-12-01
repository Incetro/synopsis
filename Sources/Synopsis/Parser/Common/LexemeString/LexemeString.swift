//
//  File.swift
//  
//
//  Created by incetro on 11/24/20.
//

import Foundation

// MARK: - LexemeString

public struct LexemeString {

    // MARK: - Properties

    /// Target string
    public let string: String

    /// Parsed lexemes from the given string
    public let lexemes: [Lexeme]

    // MARK: - Initializers

    /// Default initializer
    /// - Parameter string: target string
    public init(_ string: String) {
        self.string = string
        if string.isEmpty {
            lexemes = []
        } else {
            lexemes = LexemeString.returnLexeme(
                currentIndex: string.startIndex,
                string: string,
                currentLexeme: Lexeme(
                    left: string.startIndex,
                    right: string.startIndex,
                    kind: .sourceCode
                ),
                initial: []
            )
        }
    }

    // MARK: - Useful

    /// Return true if the given index is in the comment range
    /// - Parameter index: some index
    /// - Returns: true if the given index is in the comment range
    public func inCommentRange(_ index: String.Index) -> Bool {
        if !string.indices.contains(index) || string.endIndex == index {
            return false
        }
        for lexeme in lexemes where (lexeme.left...lexeme.right).contains(index) {
            return lexeme.isCommentKind()
        }
        return false
    }

    /// Return true if the given index is in the literal range
    /// - Parameter index: some index
    /// - Returns: true if the given index is in the literal range
    public func inStringLiteralRange(_ index: String.Index) -> Bool {
        if !string.indices.contains(index) || string.endIndex == index {
            return false
        }
        for lexeme in lexemes where (lexeme.left...lexeme.right).contains(index) {
            return lexeme.isStringLiteralKind()
        }
        return false
    }

    /// Return true if the given index is in the source code range
    /// - Parameter index: some index
    /// - Returns: true if the given index is in the source code range
    public func inSourceCodeRange(_ index: String.Index) -> Bool {
        if !string.indices.contains(index) || string.endIndex == index {
            return false
        }
        for lexeme in lexemes where (lexeme.left...lexeme.right).contains(index) {
            return lexeme.isSourceCodeKind()
        }
        return false
    }

    // MARK: - Private

    /// Translates the given string to lexemes
    /// - Parameters:
    ///   - currentIndex: start index
    ///   - string: target string
    ///   - currentLexeme: current Lexeme instance
    ///   - initial: initial lexemes data
    /// - Returns: string as lexemes
    private static func returnLexeme(
        currentIndex: String.Index,
        string: String,
        currentLexeme: Lexeme,
        initial: [Lexeme]
    ) -> [Lexeme] {
        if string.endIndex == currentIndex {
            return initial + [currentLexeme]
        } else {
            switch currentLexeme.kind {
            case .sourceCode:
                if string.detectInlineComment(startingAt: currentIndex) {
                    return returnLexeme(
                        currentIndex: string.index(after: currentIndex),
                        string: string,
                        currentLexeme: Lexeme(
                            left: currentIndex,
                            right: currentIndex,
                            kind: .inlineComment
                        ),
                        initial: initial + [currentLexeme]
                    )
                }
                if string.detectBlockComment(startingAt: currentIndex) {
                    return returnLexeme(
                        currentIndex: string.index(after: currentIndex),
                        string: string,
                        currentLexeme: Lexeme(
                            left: currentIndex,
                            right: currentIndex,
                            kind: .blockComment
                        ),
                        initial: initial + [currentLexeme]
                    )
                }
                if string.detectTextLiteral(startingAt: currentIndex) {
                    return returnLexeme(
                        currentIndex: string.index(currentIndex, offsetBy: 3),
                        string: string,
                        currentLexeme: Lexeme(
                            left: currentIndex,
                            right: currentIndex,
                            kind: .textLiteral
                        ),
                        initial: initial + [currentLexeme.adjusted(right: string.index(currentIndex, offsetBy: 2))]
                    )
                }
                if string.detectStringLiteral(startingAt: currentIndex) {
                    return returnLexeme(
                        currentIndex: string.index(after: currentIndex),
                        string: string,
                        currentLexeme: Lexeme(
                            left: currentIndex,
                            right: currentIndex,
                            kind: .stringLiteral
                        ),
                        initial: initial + [currentLexeme]
                    )
                }
                return returnLexeme(
                    currentIndex: string.index(after: currentIndex),
                    string: string,
                    currentLexeme: currentLexeme.adjusted(right: currentIndex),
                    initial: initial
                )
            case .blockComment:
                if string.detectBlockComment(endingAt: currentIndex) {
                    return returnLexeme(
                        currentIndex: string.index(after: currentIndex),
                        string: string,
                        currentLexeme: Lexeme(
                            left: currentIndex,
                            right: currentIndex,
                            kind: .sourceCode
                        ),
                        initial: initial + [currentLexeme]
                    )
                }
                return returnLexeme(
                    currentIndex: string.index(after: currentIndex),
                    string: string,
                    currentLexeme: currentLexeme.adjusted(right: currentIndex),
                    initial: initial
                )
            case .inlineComment:
                if string.detectInlineComment(endingAt: currentIndex) {
                    return returnLexeme(
                        currentIndex: string.index(after: currentIndex),
                        string: string,
                        currentLexeme: Lexeme(
                            left: currentIndex,
                            right:  currentIndex,
                            kind: .sourceCode
                        ),
                        initial: initial + [currentLexeme]
                    )
                }
                return returnLexeme(
                    currentIndex: string.index(after: currentIndex),
                    string: string,
                    currentLexeme: currentLexeme.adjusted(right: currentIndex),
                    initial: initial
                )
            case .stringLiteral:
                if string.detectStringLiteral(endingAt: currentIndex) {
                    return returnLexeme(
                        currentIndex: string.index(after: currentIndex),
                        string: string,
                        currentLexeme: Lexeme(
                            left: currentIndex,
                            right: currentIndex,
                            kind: .sourceCode
                        ),
                        initial: initial + [currentLexeme]
                    )
                }
                return returnLexeme(
                    currentIndex: string.index(after: currentIndex),
                    string: string,
                    currentLexeme: currentLexeme.adjusted(right: currentIndex),
                    initial: initial
                )
            case .textLiteral:
                if string.detectTextLiteral(endingAt: currentIndex) {
                    return returnLexeme(
                        currentIndex: string.index(currentIndex, offsetBy: 3),
                        string: string,
                        currentLexeme: Lexeme(
                            left: currentIndex,
                            right: currentIndex,
                            kind: .sourceCode
                        ),
                        initial: initial + [currentLexeme.adjusted(right: string.index(currentIndex, offsetBy: 2))]
                    )
                }
                return returnLexeme(
                    currentIndex: string.index(after: currentIndex),
                    string: string,
                    currentLexeme: currentLexeme.adjusted(right: currentIndex),
                    initial: initial
                )
            }
        }
    }

    // MARK: - Lexeme

    public struct Lexeme {

        // MARK: - Properties

        let left: String.Index
        var right: String.Index
        let kind: Kind

        // MARK: - Useful

        /// Returns true if the current
        /// lexeme is a comment
        public func isCommentKind() -> Bool {
            switch kind {
            case .inlineComment,
                 .blockComment:
                return true
            default:
                return false
            }
        }

        /// Returns true if the current
        /// lexeme is a string literal
        public func isStringLiteralKind() -> Bool {
            switch kind {
            case .stringLiteral,
                 .textLiteral:
                return true
            default:
                return false
            }
        }

        /// Returns true if the current
        /// lexeme is a souce code
        public func isSourceCodeKind() -> Bool {
            switch kind {
            case .sourceCode:
                return true
            default:
                return false
            }
        }

        /// Adjust current lexeme with
        /// the given position
        /// - Parameter right: right position
        /// - Returns: new lexeme instance
        public func adjusted(right: String.Index) -> Lexeme {
            Lexeme(left: left, right: right, kind: kind)
        }

        // MARK: - Kind

        public enum Kind {
            case sourceCode
            case inlineComment
            case blockComment
            case stringLiteral
            case textLiteral
        }
    }
}
