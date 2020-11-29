//
//  File.swift
//  
//
//  Created by incetro on 11/28/20.
//

import Foundation
import SourceKittenFramework

// MARK: - ExtensionParser

final class ExtensionParser<S: SourceCode>: ExtensibleParser<S, ExtensionSpecification> {

    public override func isRawExtensibleDescription(_ element: Parameters) -> Bool {
        SwiftDeclarationKind.extension.rawValue == element.kind
    }
}
