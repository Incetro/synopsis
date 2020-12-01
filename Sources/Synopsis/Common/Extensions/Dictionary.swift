//
//  File.swift
//  
//
//  Created by incetro on 11/23/20.
//

import SourceKittenFramework

// MARK: - Dictionary

public extension Dictionary where Key == String {

    var attributes: [String] {
        (self["key.attributes"] as? [Parameters])?.compactMap { $0["key.attribute"] as? String } ?? []
    }

    var accessibility: String? {
        self["key.accessibility"] as? String
    }

    var offset: Int {
        self[.offset].unwrap(as: Int.self)
    }

    var length: Int {
        self[.length].unwrap(as: Int.self)
    }

    var parsedDeclaration: String {
        if let value = self[.parsedDeclaration] as? String {
            return value
        }
        preconditionFailure("""
        !!! ATTENTION !!!
        It looks like Swift compiler can't reach your source code file. Also ot can be SourceKitten errorr.
        Sometimes SourceKitten cannot build 'parsedDeclaration' and we also don't like it. We cannot control it
        but if you find a solution please tell us and we will fix it immediately. One day we experienced the same problem
        and we fixed it, maybe it may happen one more time :)

        OR
        This usually happens when provided path does not exist or when this path contains relative injections like ".":

        /Users/user/Projects/MyProject/./Sources
                                       ^~~~~~~~~

        Swift compiler can't navigate through "." and ".." yet. Sorry about that.
        Also, Swift compiler uses absolute paths, so we concatenate your relative paths with current working directory.

        Please make sure your "-input" folder reads like "Sources/Classes" and not like "./Sources/Classes".
        (or provide absolute path, if applicable)
        !!! ATTENTION !!!

        """)
    }

    var subsctructure: [Parameters] {
        self[.substructure] as? [Parameters] ?? []
    }

    var comment: String? {
        self[.documentationComment] as? String
    }

    var name: String {
        self[.name].unwrap(as: String.self)
    }

    var inheritedTypes: [String] {
        let inheritedTypes = self[SwiftDocKey.inheritedtypes] as? [Parameters] ?? []
        return inheritedTypes.map { $0[SwiftDocKey.name].unwrap(as: String.self) }
    }

    var typename: String {
        self[.typeName].unwrap(as: String.self)
    }

    var kind: String? {
        self[.kind] as? String
    }

    var bodyOffset: Int? {
        self[.bodyOffset] as? Int
    }

    var bodyLength: Int? {
        self[.bodyLength] as? Int
    }

    subscript(key: SwiftDocKey) -> Value? {
        self[key.rawValue]
    }
}

