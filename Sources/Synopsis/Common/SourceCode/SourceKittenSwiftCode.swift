//
//  File.swift
//  
//
//  Created by incetro on 11/23/20.
//

import Files
import Foundation

// MARK: - SourceKittenSwiftCode

/// Any swift source code file
/// parsed with SourceKitten
public struct SourceKittenSwiftCode: SourceCode {

    // MARK: - Properties

    /// Target file url
    public let fileURL: URL

    /// A dictionary which describes your source code
    /// from file at `fileURL`
    public let sourceCodeDictionary: [String: Any]

    /// Target file content
    public var content: String {
        let content = try? File(path: fileURL.absoluteString).readAsString()
        return content ?? ""
    }

    /// Source code substructure representation
    public var substructure: [Parameters] {
        guard let dictionary = sourceCodeDictionary[fileURL.absoluteString] as? Parameters else {
            return []
        }
        return dictionary.substructure
    }
}
