//
//  File.swift
//  
//
//  Created by incetro on 11/23/20.
//

import Foundation

// MARK: - Optional

extension Optional {

    /// Forcely unwraps current value/object
    /// - Parameters:
    ///   - hint: error reason
    ///   - file: file with possible error
    ///   - line: line with possible error
    /// - Returns: unwrapped non-optional object
    public func unwrap(
        _ hint: @autoclosure () -> String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Wrapped {
        guard let unwrapped = self else {
            var message = "Required value was nil in \(file), at line \(line)"
            if let hint = hint() {
                message.append(". Debugging hint: \(hint)")
            }
            preconditionFailure(message)
        }
        return unwrapped
    }

    /// Forcely unwraps current value/object as the given type
    /// - Parameters:
    ///   - type: target type for casting
    ///   - hint: error reason
    ///   - file: file with possible error
    ///   - line: line with possible error
    /// - Returns: unwrapped non-optional object
    public func unwrap<T>(
        as type: T.Type,
        withHint hint: @autoclosure () -> String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> T {
        guard let unwrapped = self as? T else {
            var message = "Required value cannot be converted to '\(T.self)' in \(file), at line \(line)"
            if let hint = hint() {
                message.append(". Debugging hint: \(hint)")
            }
            preconditionFailure(message)
        }
        return unwrapped
    }
}
