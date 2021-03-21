//
//  ExtensionParser.swift
//  Synopsis
//
//  Created by incetro on 11/28/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

// MARK: - ExtensionParser

final class ExtensionParser<S: SourceCode>: ExtensibleParser<S, ExtensionSpecification> {

    public override func isRawExtensibleSpecification(_ element: Parameters) -> Bool {
        SwiftDeclarationKind.extension.rawValue == element.kind
    }
}
