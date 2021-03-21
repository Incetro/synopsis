//
//  TypeSpecification.swift
//  Synopsis
//
//  Created by incetro on 11/24/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation

// MARK: - TypeSpecification

/// Type of class properties, methods,
/// method arguments, variables etc.
public indirect enum TypeSpecification {

    // MARK: - Cases

    /// Boolean
    case boolean

    /// Anything, which contains "Int" in it:
    /// Int, Int16, Int32, Int64, UInt etc
    case integer

    /// Float
    case floatingPoint

    /// Double
    case doublePrecision

    /// String
    case string

    /// Date (formerly known as NSDate)
    case date

    /// Data (formerly known as NSData)
    case data

    /// Void
    case void

    /// Anything optional; wraps actual type
    case optional(wrapped: TypeSpecification)

    /// Classes, structures, enums & protocol.
    /// Except for Date, Data and collections of any kind
    case object(name: String)

    /// Array collection
    case array(element: TypeSpecification)

    /// Map/dictionary collection
    case map(key: TypeSpecification, value: TypeSpecification)

    /// Generic type.
    ///
    /// Like `object`, contains type name
    /// and also contains type for item in corner brakets
    case generic(name: String, constraints: [TypeSpecification])

    /// Returns current type as non-optional type
    public var unwrapped: TypeSpecification {
        switch self {
        case .optional(wrapped: let type):
            return type.unwrapped
        default:
            return self
        }
    }
}

// MARK: - CustomStringConvertible

extension TypeSpecification: CustomStringConvertible {

    public var description: String {
        switch self {
        case .boolean:
            return "Bool"
        case .integer:
            return "Int"
        case .floatingPoint:
            return "Float"
        case .doublePrecision:
            return "Double"
        case .string:
            return "String"
        case .date:
            return "Date"
        case .data:
            return "Data"
        case .void:
            return "Void"
        case let .optional(wrapped):
            return "\(wrapped)?"
        case let .object(name):
            return "\(name)"
        case let .array(item):
            return "[\(item)]"
        case let .map(key, value):
            return "[\(key): \(value)]"
        case let .generic(name, constraints):
            let constraintsString: String = constraints.map { "\($0)" }.joined(separator: ", ")
            return "\(name)<\(constraintsString)>"
        }
    }
}

// MARK: - Equatable

extension TypeSpecification: Equatable {

    public static func == (left: TypeSpecification, right: TypeSpecification) -> Bool {
        switch (left, right) {
        case (.boolean, .boolean):
            return true
        case (.integer, .integer):
            return true
        case (.floatingPoint, .floatingPoint):
            return true
        case (.doublePrecision, .doublePrecision):
            return true
        case (.date, .date):
            return true
        case (.data, .data):
            return true
        case (.string, .string):
            return true
        case (.void, .void):
            return true
        case (let .optional(wrappedLeft), let .optional(wrappedRight)):
            return wrappedLeft == wrappedRight
        case (let .object(name: leftName), let .object(name: rightName)):
            return leftName == rightName
        case (let .array(element: leftItem), let .array(element: rightItem)):
            return leftItem == rightItem
        case (let .map(key: leftKey, value: leftValue), let .map(key: rightKey, value: rightValue)):
            return leftKey == rightKey && leftValue == rightValue
        case (let .generic(name: leftName, constraints: leftConstraints), let .generic(name: rightName, constraints: rightConstraints)):
            return leftName == rightName && leftConstraints == rightConstraints
        default:
            return false
        }
    }
}

// MARK: - Specification

extension TypeSpecification: Specification {

    /// Write down own source code.
    public var verse: String {
        switch self {
        case .boolean:
            return "Bool"
        case .integer:
            return "Int"
        case .floatingPoint:
            return "Float"
        case .doublePrecision:
            return "Double"
        case .string:
            return "String"
        case .date:
            return "Date"
        case .data:
            return "Data"
        case .void:
            return "Void"
        case .optional(let wrapped):
            return "\(wrapped.verse)?"
        case .object(let name):
            return name
        case .array(let element):
            return "[\(element.verse)]"
        case .map(let key, let value):
            return "[\(key.verse): \(value.verse)]"
        case .generic(let name, let constraints):
            let constraintsString: String = constraints.map { "\($0.verse)" }.joined(separator: ", ")
            return "\(name)<\(constraintsString)>"
        }
    }
}
