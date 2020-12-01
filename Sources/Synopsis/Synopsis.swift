//
//  Synopsis.swift
//  Synopsis
//
//  Created by incetro on 11/22/20.
//

import Files
import Foundation
import source_kitten_adapter

// MARK: - Synopsis

public final class Synopsis<Provider: SourceCodeProvider> {

    // MARK: - Properties

    /// SourceCodeProvider instance
    private let sourceCodeProvider: Provider

    /// EnumParser instance
    private lazy var enumParser = EnumParser<Provider.S>()

    /// ProtocolParser instance
    private lazy var protocolParser = ProtocolParser<Provider.S>()

    /// StructureParser instance
    private lazy var structureParser = StructureParser<Provider.S>()

    /// ClassParser instance
    private lazy var classParser = ClassParser<Provider.S>()

    /// ClassParser instance
    private lazy var functionParser = FunctionParser<Provider.S, FunctionSpecification>()

    /// ExtensionParser instance
    private lazy var extensionParser = ExtensionParser<Provider.S>()

    // MARK: - Initializers

    /// Default initializer
    /// - Parameter sourceCodeProvider: target source code provider instance
    public init(sourceCodeProvider: Provider) {
        self.sourceCodeProvider = sourceCodeProvider
    }

    // MARK: - Useful

    /// Returns specifications for the given urls
    /// - Parameter files: some file/folder urls
    /// - Returns: specifications for the given urls
    public func specifications(from files: [URL]) -> SynopsisResult<Specifications> {
        let files = fileURLs(from: files)
        let sourceCodeResult = sourceCodeProvider.sourceCode(from: files)
        let specifications = Specifications(
            enums: enumParser.parse(source: sourceCodeResult.result),
            protocols: protocolParser.parse(source: sourceCodeResult.result),
            structures: structureParser.parse(source: sourceCodeResult.result),
            classes: classParser.parse(source: sourceCodeResult.result),
            functions: functionParser.parse(source: sourceCodeResult.result),
            extensions: extensionParser.parse(source: sourceCodeResult.result)
        )
        return SynopsisResult(result: specifications, errors: sourceCodeResult.errors)
    }

    /// Returns specifications for the given url
    /// - Parameter files: some file/folder url
    /// - Returns: specifications for the given url
    public func specifications(from url: URL) throws -> SynopsisResult<Specifications> {
        specifications(from: [url])
    }

    // MARK: - Private

    /// Checks if some of the working urls is folders
    /// and if it is they will be converted to files urls
    /// - Parameter urls: target urls
    /// - Returns: only file urls
    private func fileURLs(from urls: [URL]) -> [URL] {
        var result: [URL] = []
        for url in urls {
            if let folder = try? Folder(path: url.absoluteString) {
                let files = folder.files
                    .filter { $0.extension == "swift" }
                    .compactMap { URL(string: $0.path) }
                result.append(contentsOf: files)
            } else {
                result.append(url)
            }
        }
        return result
    }
}
