//
//  CompositionParser.swift
//  Synopsis
//
//  Created by incetro on 3/18/21.
//

import Foundation

// MARK: - CompositionParser

public class CompositionParser<S: SourceCode> {

    // MARK: - Internal

    /// Parses classes from the given substructure
    /// - Parameters:
    ///   - substructure: target substructure array
    ///   - fileURL: current file url
    ///   - content: current file content
    /// - Returns: parsed classes specifications
    func classes(
        from substructure: [Parameters],
        forFileAt fileURL: URL,
        withContent content: String
    ) -> [ClassSpecification] {
        let classParser = ClassParser<S>()
        return substructure
            .filter { classParser.isRawExtensibleSpecification($0) }
            .map {
                classParser.parse(
                    extensibleDictionary: $0,
                    forFileAt: fileURL,
                    withContent: content
                )
            }
    }

    /// Parses structs from the given substructure
    /// - Parameters:
    ///   - substructure: target substructure array
    ///   - fileURL: current file url
    ///   - content: current file content
    /// - Returns: parsed structs specifications
    func structs(
        from substructure: [Parameters],
        forFileAt fileURL: URL,
        withContent content: String
    ) -> [StructureSpecification] {
        let structParser = StructureParser<S>()
        return substructure
            .filter { structParser.isRawExtensibleSpecification($0) }
            .map {
                structParser.parse(
                    extensibleDictionary: $0,
                    forFileAt: fileURL,
                    withContent: content
                )
            }
    }

    /// Parses protocols from the given substructure
    /// - Parameters:
    ///   - substructure: target substructure array
    ///   - fileURL: current file url
    ///   - content: current file content
    /// - Returns: parsed protocols specifications
    func protocols(
        from substructure: [Parameters],
        forFileAt fileURL: URL,
        withContent content: String
    ) -> [ProtocolSpecification] {
        let protocolParser = ProtocolParser<S>()
        return substructure
            .filter { protocolParser.isRawExtensibleSpecification($0) }
            .map {
                protocolParser.parse(
                    extensibleDictionary: $0,
                    forFileAt: fileURL,
                    withContent: content
                )
            }
    }

    /// Parses protocols from the given substructure
    /// - Parameters:
    ///   - substructure: target substructure array
    ///   - fileURL: current file url
    ///   - content: current file content
    /// - Returns: parsed protocols specifications
    func enums(
        from substructure: [Parameters],
        forFileAt fileURL: URL,
        withContent content: String
    ) -> [EnumSpecification] {
        let enumsParser = EnumParser<S>()
        return substructure
            .filter { enumsParser.isRawEnumSpecification($0) }
            .map {
                enumsParser.parse(
                    enumDictionary: $0,
                    forFileAt: fileURL,
                    withContent: content
                )
            }
    }
}
