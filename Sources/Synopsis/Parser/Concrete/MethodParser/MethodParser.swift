//
//  File.swift
//  
//
//  Created by incetro on 11/25/20.
//

import Foundation
import SourceKittenFramework

// MARK: - MethodParser

public final class MethodParser<S: SourceCode>: FunctionParser<S, MethodSpecification> {

    public override func isRawFunctionSpecification(_ element: Parameters) -> Bool {
        guard let kind = element.kind else { return false }
        return SwiftDeclarationKind.functionMethodInstance.rawValue == kind
            || SwiftDeclarationKind.functionMethodStatic.rawValue   == kind
            || SwiftDeclarationKind.functionMethodClass.rawValue    == kind
    }
}
