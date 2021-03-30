//
//  File.swift
//  
//
//  Created by incetro on 3/29/21.
//

import Foundation

// MARK: - GenericParser

public final class GenericParser {

    private func parse(rawString generic: String) -> GenericSpecification {
        let genericComponents = generic.components(separatedBy: ":")
        let name = genericComponents.first.unwrap()
        if genericComponents.count > 1, let inheritedTypesStr = genericComponents.last {
            let inheritedTypes = inheritedTypesStr.components(separatedBy: "&")
            return GenericSpecification(name: name, inheritedTypes: inheritedTypes)
        } else {
            return GenericSpecification(name: name)
        }
    }

    public func parse(functionDeclaration declaration: String) -> [GenericSpecification] {
        guard let functionDeclarationWithoutReturnType = declaration.components(separatedBy: "->").first else {
            return []
        }
        guard let functionDeclarationWithoutParameters = functionDeclarationWithoutReturnType.components(separatedBy: "(").first else {
            return []
        }
        guard ["<", ">"].allSatisfy(functionDeclarationWithoutParameters.contains) else {
            return []
        }
        guard let genericsDeclaration = functionDeclarationWithoutParameters
                .components(separatedBy: "<").last?
                .components(separatedBy: ">").first else {
            return []
        }
        let genericStrings = genericsDeclaration
            .components(separatedBy: .whitespacesAndNewlines)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: ",")
        let generics = genericStrings.map(parse(rawString:))
        return generics
    }
}
