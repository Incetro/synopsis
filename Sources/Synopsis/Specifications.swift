//
//  File.swift
//  
//
//  Created by incetro on 11/23/20.
//

import Foundation

// MARK: - Specifications

public struct Specifications {

    // MARK: - Properties

    /// Enumerations specifications
    public let enums: [EnumSpecification]

    /// Protocols specifications
    public let protocols: [ProtocolSpecification]

    /// Structures specifications
    public let structures: [StructureSpecification]

    /// Classes specifications
    public let classes: [ClassSpecification]

    /// Functions specifications
    public let functions: [FunctionSpecification]

    /// Extensions specifications
    public let extensions: [ExtensionSpecification]

    // MARK: - Consolidation

    /// Enums which are consolidated with their extensions
    var consolidatedEnums: [EnumSpecification: [ExtensionSpecification]] {
        var consolidated: [EnumSpecification: [ExtensionSpecification]] = [:]
        for `enum` in enums {
            consolidated[`enum`] = extensions.filter { $0.name == `enum`.name }
        }
        return consolidated
    }

    /// Protocols which are consolidated with their extensions
    var consolidatedProtocols: [ProtocolSpecification: [ExtensionSpecification]] {
        var consolidated: [ProtocolSpecification: [ExtensionSpecification]] = [:]
        for `protocol` in protocols {
            consolidated[`protocol`] = extensions.filter { $0.name == `protocol`.name }
        }
        return consolidated
    }

    /// Structures which are consolidated with their extensions
    var consolidatedStructures: [StructureSpecification: [ExtensionSpecification]] {
        var consolidated: [StructureSpecification: [ExtensionSpecification]] = [:]
        for structure in structures {
            consolidated[structure] = extensions.filter { $0.name == structure.name }
        }
        return consolidated
    }

    /// Classes which are consolidated with their extensions
    var consolidatedClasses: [ClassSpecification: [ExtensionSpecification]] {
        var consolidated: [ClassSpecification: [ExtensionSpecification]] = [:]
        for `class` in classes {
            consolidated[`class`] = extensions.filter { $0.name == `class`.name }
        }
        return consolidated
    }
}
