//
//  String.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - String

public extension String {

    func detectInlineComment(startingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("///")
    }

    func detectInlineComment(endingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("\n")
    }

    func detectBlockComment(startingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("/*")
    }

    func detectBlockComment(endingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("*/")
    }

    func detectTextLiteral(startingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("\"\"\"\n")
    }

    func detectTextLiteral(endingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("\"\"\"")
    }

    func detectStringLiteral(startingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("\"")
    }

    func detectStringLiteral(endingAt index: String.Index) -> Bool {
        detectStringLiteral(startingAt: index)
    }

    func truncateUntilExist(word: String) -> Substring {
        if let range = range(of: word) {
            return self[range.lowerBound...].dropFirst()
                .truncateUntilExist(word: word)
        }
        return Substring(self)
    }

    func truncateLeadingWhitespace() -> Substring {
        if hasPrefix(" ") {
            return dropFirst().truncateLeadingWhitespace()
        }
        if hasPrefix("\n") {
            return dropFirst().truncateLeadingWhitespace()
        }
        return Substring(self)
    }

    func truncateUntil(word: String, deleteWord: Bool) -> Substring {
        guard let wordRange = range(of: word) else { return Substring(self) }
        return deleteWord ? self[wordRange.upperBound...] : self[wordRange.lowerBound...]
    }

    func truncateAfter(word: String, deleteWord: Bool) -> Substring {
        guard let wordRange = range(of: word) else { return Substring(self) }
        return deleteWord ? self[..<wordRange.lowerBound] : self[..<wordRange.upperBound]
    }

    func firstWord(sentenceDividers: [String] = ["\n", " ", ".", ",", ";", ":"]) -> Substring {
        for divider in sentenceDividers where contains(divider) {
            return truncateAfter(word: divider, deleteWord: true)
                .firstWord(sentenceDividers: sentenceDividers)
        }
        return Substring(self)
    }

    func truncateInlineCommentOpening() -> String {
        if hasPrefix("///") {
            return String(dropFirst().dropFirst().dropFirst())
                .truncateInlineCommentOpening()
        }
        return self
    }

    var indent: String {
        self
            .components(separatedBy: "\n")
            .map { $0.isEmpty ? $0 : "    " + $0 }
            .joined(separator: "\n")
    }

    var unindent: String {
        self
            .components(separatedBy: "\n")
            .map { $0.contains("    ")
                ? String($0.truncateUntil(word: "    ", deleteWord: true))
                : $0
            }
            .joined(separator: "\n")
    }

    func prefixEachLine(with prefix: String) -> String {
        self
            .components(separatedBy: "\n")
            .map { prefix + $0 }
            .joined(separator: "\n")
    }

    func enclosed(byLeft left: String, andRight right: String) -> String {
        if isEmpty { return "" }
        return left + self + right
    }

    func contains(_ string: String, atLeast count: Int) -> Bool {
        components(separatedBy: string).count - 1 >= count
    }
}

// MARK: - Substring

public extension Substring {

    func detectInlineComment(startingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("///")
    }

    func detectInlineComment(endingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("\n")
    }

    func detectBlockComment(startingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("/*")
    }

    func detectBlockComment(endingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("*/")
    }

    func detectTextLiteral(startingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("\"\"\"\n")
    }

    func detectTextLiteral(endingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("\"\"\"")
    }

    func detectStringLiteral(startingAt index: String.Index) -> Bool {
        self[index...].hasPrefix("\"")
    }

    func detectStringLiteral(endingAt index: String.Index) -> Bool {
        detectStringLiteral(startingAt: index)
    }

    func truncateUntilExist(word: String) -> Substring {
        if let range = self.range(of: word) {
            return self[range.lowerBound...]
                .dropFirst()
                .truncateUntilExist(word: word)
        }
        return self
    }

    func truncateAfter(word: String, deleteWord: Bool) -> Substring {
        guard let wordRange = range(of: word) else { return self }
        return deleteWord ? self[..<wordRange.lowerBound] : self[..<wordRange.upperBound]
    }

    func truncateLeadingWhitespace() -> Substring {
        if hasPrefix(" ") {
            return dropFirst().truncateLeadingWhitespace()
        }
        if hasPrefix("\n") {
            return dropFirst().truncateLeadingWhitespace()
        }
        return self
    }

    func firstWord(sentenceDividers: [String] = ["\n", " ", ".", ",", ";", ":"]) -> Substring {
        for divider in sentenceDividers where contains(divider) {
            return truncateAfter(word: divider, deleteWord: true)
                .firstWord(sentenceDividers: sentenceDividers)
        }
        return self
    }
}
