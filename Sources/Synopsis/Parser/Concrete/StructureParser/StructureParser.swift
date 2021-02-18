//
//  File.swift
//  
//
//  Created by incetro on 11/27/20.
//

import Foundation
import SourceKittenFramework

// MARK: - StructureParser

public final class StructureParser<S: SourceCode>: ExtensibleParser<S, StructureSpecification> {

    public override func isRawExtensibleSpecification(_ element: Parameters) -> Bool {
        SwiftDeclarationKind.struct.rawValue == element.kind
    }
}
