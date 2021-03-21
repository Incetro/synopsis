//
//  ProtocolParser.swift
//  Synopsis
//
//  Created by incetro on 11/27/20.
//  Copyright © 2020 Incetro Inc. All rights reserved.
//

import Foundation
import SourceKittenFramework

// MARK: - ProtocolParser

public final class ProtocolParser<S: SourceCode>: ExtensibleParser<S, ProtocolSpecification> {

    public override func isRawExtensibleSpecification(_ element: Parameters) -> Bool {
        SwiftDeclarationKind.`protocol`.rawValue == element.kind
    }
}
