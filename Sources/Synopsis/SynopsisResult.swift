//
//  File.swift
//  
//
//  Created by incetro on 11/28/20.
//

import Foundation

// MARK: - SynopsisResult

public struct SynopsisResult<T> {

    // MARK: - Properties

    /// Result value
    public let result: T

    /// Some errors
    public let errors: [SynopsisError]
}
