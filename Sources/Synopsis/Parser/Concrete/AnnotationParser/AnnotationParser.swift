//
//  AnnotationParser.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - AnnotationParser

public final class AnnotationParser {

    /// Find all available annotations inside the given comment
    /// - Parameter comment: some comment string
    /// - Returns: all available annotations inside the given comment
    public func parse(comment: String) -> [AnnotationSpecification] {
        var comment = comment
        var annotaions: [AnnotationSpecification] = []
        while comment.contains("@") {
            let annotationName = String(comment.truncateUntil(word: "@", deleteWord: true).firstWord())
            comment = String(comment.truncateUntil(word: "@" + annotationName, deleteWord: true))
            let annotationValue: String?
            if comment.hasPrefix("\n")
                || comment.hasPrefix(" \n")
                || comment.hasPrefix(";")
                || comment.hasPrefix(";\n")
                || comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                annotationValue = nil
            } else {
                annotationValue = String(comment.truncateLeadingWhitespace().firstWord(sentenceDividers: ["\n", " ", ";"]))
            }
            annotaions.append(
                AnnotationSpecification(
                    name: annotationName,
                    value: annotationValue,
                    declaration: nil
                )
            )
        }
        return annotaions
    }
}
