//
//  File.swift
//  
//
//  Created by incetro on 11/27/20.
//

import Foundation
import SourceKittenFramework

// MARK: - ClassParser

public final class ClassParser<S: SourceCode>: ExtensibleParser<S, ClassSpecification> {

    public override func isRawExtensibleSpecification(_ element: Parameters) -> Bool {
        SwiftDeclarationKind.class.rawValue == element.kind
    }
}
