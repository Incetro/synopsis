//
//  File.swift
//  
//
//  Created by incetro on 11/23/20.
//

import Foundation

// MARK: - SourceCodeProvider

public protocol SourceCodeProvider {

    associatedtype S: SourceCode

    /// Returns source code based on the given urls
    /// - Parameter urls: some url with some Swift source code
    func sourceCode(from urls: [URL]) -> SynopsisResult<[S]>
}
