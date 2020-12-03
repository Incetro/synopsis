//
//  File.swift
//  
//
//  Created by incetro on 11/25/20.
//

import Foundation

// MARK: - FunctionSpecification

public class FunctionSpecification: Specification, CustomDebugStringConvertible {

    // MARK: - Properties

    /// Documentation comment
    public let comment: String?

    /// Function annotation.
    /// Function annotations are located inside block comment above the declaration.
    public let annotations: [AnnotationSpecification]

    /// Access visibility
    public let accessibility: AccessibilitySpecification

    /// Method attributes (like `override`, `mutating` etc.)
    public let attributes: [AttributeSpecification]

    /// Function name
    ///
    /// Almost like signature, but without argument types
    public let name: String

    /// Function arguments
    public let arguments: [ArgumentSpecification]

    /// Return type
    public let returnType: TypeSpecification?

    /// Function declaration line
    public let declaration: Declaration

    /// Kind
    public let kind: Kind

    /// Function body, if available
    public let body: String?

    /// True if we need to indent our parameters comments
    /// by longest parameters string:
    ///
    /// if indentCommentByLongestParameter is true that we'll have:
    /// ```
    /// func obtainUser(
    ///     withFirstName firstName: String, /// first name comment
    ///     secondName: String,              /// first name comment
    ///     age: Int,                        /// first name comment
    ///     id: String                       /// first name comment
    /// )
    /// ```
    ///
    /// Otherwise:
    /// ```
    /// func obtainUser(
    ///     withFirstName firstName: String, /// first name comment
    ///     secondName: String, /// first name comment
    ///     age: Int, /// first name comment
    ///     id: String /// first name comment
    /// )
    /// ```
    ///
    public let indentCommentByLongestParameter: Bool = true

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - comment: documentation comment
    ///   - annotations: function annotations
    ///   - accessibility: access visibility
    ///   - name: function name
    ///   - arguments: function arguments
    ///   - returnType: return type
    ///   - declaration: function declaration line
    ///   - kind: kind value
    ///   - body: function body, if available
    public required init(
        comment: String?,
        annotations: [AnnotationSpecification],
        accessibility: AccessibilitySpecification,
        attributes: [AttributeSpecification],
        name: String,
        arguments: [ArgumentSpecification],
        returnType: TypeSpecification?,
        declaration: Declaration,
        kind: Kind,
        body: String?
    ) {
        self.comment       = comment
        self.annotations   = annotations
        self.accessibility = accessibility
        self.attributes    = attributes
        self.name          = name
        self.arguments     = arguments
        self.returnType    = returnType
        self.declaration   = declaration
        self.kind          = kind
        self.body          = body
    }

    // MARK: - Template

    /// Make a template for later code generation
    /// - Parameters:
    ///   - comment: documentation comment
    ///   - accessibility: access visibility
    ///   - name: function name
    ///   - arguments: function arguments
    ///   - returnType: return type
    ///   - kind: kind value
    ///   - body: function body, if available
    /// - Throws: FunctionTemplateError
    /// - Returns: a template for later code generation
    public class func template(
        comment: String?,
        accessibility: AccessibilitySpecification,
        attributes: [AttributeSpecification],
        name: String,
        arguments: [ArgumentSpecification],
        returnType: TypeSpecification?,
        kind: Kind,
        body: String?
    ) throws -> Self {
        if !checkRoundBrackets(inName: name) {
            throw FunctionTemplateError.nameLacksRoundBrackets(name: name)
        }
        return self.init(
            comment: comment,
            annotations: [],
            accessibility: accessibility,
            attributes: attributes,
            name: name,
            arguments: arguments,
            returnType: returnType,
            declaration: Declaration.mock,
            kind: kind,
            body: body
        )
    }

    // MARK: - Private

    private static func checkRoundBrackets(inName name: String) -> Bool {
        let lex = LexemeString(name)
        var left = false
        var right = false
        for lexeme in lex.lexemes where lexeme.isSourceCodeKind() {
            if name[lexeme.left...lexeme.right].contains("(") {
                left = true
            }
            if name[lexeme.left...lexeme.right].contains(")") {
                right = true
            }
        }

        return left && right
    }

    // MARK: - FunctionTemplateError

    public enum FunctionTemplateError: Error {
        case nameLacksRoundBrackets(name: String)
    }

    // MARK: - Kind

    public enum Kind {

        case free
        case `class`
        case `static`
        case instance

        public var verse: String {
            switch self {
            case .class:
                return "class"
            case .static:
                return "static"
            case .instance, .free:
                return ""
            }
        }
    }

    // MARK: - CustomDebugStringConvertible

    public var debugDescription: String {
        "FUNCTION: name = \(name)" + (nil != returnType ? "; return type = \(returnType.unwrap())" : "")
    }

    // MARK: - Specification

    /// Write down own source code
    public var verse: String {

        let commentStr       = comment.map { $0.isEmpty ? "" : $0.prefixEachLine(with: "/// ") + "\n" } ?? ""
        let openBraceIndex   = name.firstIndex(of: "(").unwrap()
        let accessibilityStr = accessibility.verse.isEmpty ? "" : "\(accessibility.verse) "
        let attributesStr    = attributes
            .sorted { $0.priority > $1.priority }
            .filter { [.discardableResult, .override, .mutating].contains($0) }
            .map(\.verse)
            .joined(separator: " ")
        let funcStr          = (attributesStr.isEmpty ? "" : " ") + "func "
        let nameStr          = name[..<openBraceIndex]
        let kindStr          = kind.verse.isEmpty ? "" : "\(kind.verse) "
        let returnTypeStr    = returnType.map { $0 == .void ? "" : " -> \($0.verse)" } ?? ""
        let bodyStr          = body.map {
            $0.isEmpty
                ? " {}"
                : " {\n    \($0.truncateLeadingWhitespace())}".replacingOccurrences(of: "}}", with: "}")
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
}

// MARK: - Equatable

extension FunctionSpecification: Equatable {

    public static func ==(left: FunctionSpecification, right: FunctionSpecification) -> Bool {
        return left.comment       == right.comment
            && left.annotations   == right.annotations
            && left.accessibility == right.accessibility
            && left.name          == right.name
            && left.arguments     == right.arguments
            && left.returnType    == right.returnType
            && left.declaration   == right.declaration
            && left.kind          == right.kind
            && left.body          == right.body
    }
}
