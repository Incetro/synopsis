//
//  SourceKittenCodeProvider.swift
//  Synopsis
//
//  Created by incetro on 11/23/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Files
import Foundation
import source_kitten_adapter

// MARK: - SourceKittenCodeProvider

public final class SourceKittenCodeProvider {

    // MARK: - Properties

    /// SourceKittenAdapter instance
    private let sourceKittenAdapter: SourceKittenAdapter

    // MARK: - Initializers

    /// SourceKittenAdapter initializer
    /// - Parameter sourceKittenAdapter: SourceKittenAdapter instance
    public init(sourceKittenAdapter: SourceKittenAdapter) {
        self.sourceKittenAdapter = sourceKittenAdapter
    }

    /// Default initializer
    public convenience init() {
        self.init(sourceKittenAdapter: SourceKittenAdapterImplementation())
    }
}

// MARK: - SourceCodeProvider

extension SourceKittenCodeProvider: SourceCodeProvider {

    public func sourceCode(from urls: [URL]) -> SynopsisResult<[SourceKittenSwiftCode]> {
        var errors: [SynopsisError] = []
        var result: [SourceKittenSwiftCode] = []
        for url in urls {
            do {
                let file = try File(path: url.absoluteString)
                let content = try file.readAsString()
                guard !content.contains("synopsis:disable") else {
                    continue
                }
                let sourceCodeDictionary = try sourceKittenAdapter.dictionary(forFileAt: url.absoluteString)
                let sourceCode = SourceKittenSwiftCode(
                    fileURL: url,
                    sourceCodeDictionary: sourceCodeDictionary
                )
                result.append(sourceCode)
            } catch {
                let synopsisError = SynopsisError(description: error.localizedDescription, file: url)
                errors.append(synopsisError)
            }
        }
        return SynopsisResult(result: result, errors: errors)
    }
}
