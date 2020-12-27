import source_kitten_adapter
import ArgumentParser
import Foundation

// MARK: - Analyze

struct Analyze: ParsableCommand {

    @Argument(help: "path to source code")
    var path: String

    mutating func run() throws {
        let synopsis = Synopsis(sourceCodeProvider: SourceKittenCodeProvider())
        let specifications = try synopsis.specifications(from: URL(string: path).unwrap())
        print()
        specifications.result.enums.forEach {
            print($0.verse)
        }
        print()
        specifications.result.protocols.forEach {
            print($0.verse)
        }
        print()
        specifications.result.structures.forEach {
            print($0.verse)
        }
        print()
        specifications.result.classes.forEach {
            print($0.verse)
        }
        print()
        specifications.result.functions.forEach {
            print($0.verse)
        }
        print()
        specifications.result.extensions.forEach {
            print($0.verse)
        }
    }
}

Analyze.main()
