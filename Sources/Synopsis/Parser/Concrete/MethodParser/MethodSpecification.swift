//
//  MethodSpecification.swift
//  Synopsis
//
//  Created by incetro on 11/25/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - MethodSpecification

public final class MethodSpecification: FunctionSpecification {

    /// Is it a simple method or an initializer?
    public var isInitializer: Bool {
        name.hasPrefix("init(")
    }

    /// Is it a simple method or an initializer?
    public var isFunction: Bool {
        !isInitializer
    }

    /// Write down own source code.
    public override var verse: String {

        let commentStr: String
        if let commentExpl: String = comment, !commentExpl.isEmpty {
            commentStr = commentExpl.prefixEachLine(with: "/// ") + "\n"
        } else {
            commentStr = ""
        }

        let openBraceIndex   = name.firstIndex(of: "(").unwrap()
        let accessibilityStr = accessibility.verse.isEmpty ? "" : "\(accessibility.verse) "
        let attributesStr    = attributes
            .sorted { $0.priority > $1.priority }
            .filter { [.discardableResult, .override, .mutating].contains($0) }
            .map(\.verse)
            .joined(separator: " ")
        let funcStr          = isInitializer ? "" : (attributesStr.isEmpty ? "" : " ") + "func "
        let nameStr          = name[..<openBraceIndex]
        let kindStr          = kind.verse.isEmpty ? "" : "\(kind.verse) "
        let returnTypeStr    = returnType.map { isInitializer ? "" : $0 == .void ? "" : " -> \($0.verse)" } ?? ""
        let bodyStr          = body.map {
            $0.isEmpty
                ? " {}"
                : " {\n    \($0.unindent.truncateLeadingWhitespace())}".replacingOccurrences(of: "}}", with: "}")
        } ?? ""

        let argumentsStr: String
        if arguments.isEmpty {
            argumentsStr = ""
        } else if arguments.contains(where: { $0.comment != nil }) && indentCommentByLongestParameter {
            let longestArgumentLength = arguments.map(\.lengthWithoutComment).max().unwrap()
            argumentsStr = arguments.reduce("\n") { (result: String, argument: ArgumentSpecification) -> String in
                let currentArgumentVerse = arguments.last == argument ? argument.verse : argument.verseWithComma
                if argument.comment != nil {
                    var separatedArgumentVerse = currentArgumentVerse.components(separatedBy: "///")
                    let currentArgumentLength = separatedArgumentVerse[0]
                        .trimmingCharacters(in: .whitespacesAndNewlines).count
                    let necessarySpacesCount = longestArgumentLength - currentArgumentLength
                    let necessarySpaces = (0..<necessarySpacesCount).map { _ in " " }.joined()
                    separatedArgumentVerse.insert(necessarySpaces.appending("///"), at: 1)
                    return result + separatedArgumentVerse.joined() + "\n"
                } else {
                    return result + currentArgumentVerse + "\n"
                }
            }
        } else {
            argumentsStr = arguments.reduce("\n") { (result: String, argument: ArgumentSpecification) -> String in
                arguments.last == argument
                    ? result + argument.verse + "\n"
                    : result + argument.verseWithComma + "\n"
            }
        }

        return """
        \(commentStr)\(accessibilityStr)\(attributesStr)\(kindStr)\(funcStr)\(nameStr)(\(argumentsStr.indent))\(returnTypeStr)\(bodyStr)
        """
    }

    public override var debugDescription: String {
        if isInitializer {
            return "\(isInitializer ? "INITIALIZER" : "METHOD"): name = \(name)"
        } else {
            return "\(isInitializer ? "INITIALIZER" : "METHOD"): name = \(name)" + (nil != returnType ? "; return type = \(returnType.unwrap())" : "")
        }
    }
}
