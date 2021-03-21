//
//  SynopsisResult.swift
//  Synopsis
//
//  Created by incetro on 11/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
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
