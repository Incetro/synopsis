//
//  ClassParser.swift
//  Synopsis
//
//  Created by incetro on 11/27/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

// MARK: - ClassParser

public final class ClassParser<S: SourceCode>: ExtensibleParser<S, ClassSpecification> {

    public override func isRawExtensibleSpecification(_ element: Parameters) -> Bool {
        SwiftDeclarationKind.class.rawValue == element.kind
    }
}
