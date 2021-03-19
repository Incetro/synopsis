![](synopsis.png)

## Description

The package is designed to gather information from Swift source files and compile this information into concrete objects with
strongly typed properties containing descriptions of found symbols.

In other words, if you have a source code file like

```swift
/// Interlayer pagination metadata object
public struct PaginationMetadataPlainObject {

    /// Total object count
    let totalCount: Int

    /// Total pages count
    let pageCount: Int

    /// Current pagination page
    let currentPage: Int

    /// Page size
    let perPage: Int
}
```
— **Synopsis** will give you structurized information that there's a `struct`, it's `public` and named `PaginationMetadataPlainObject `, with no methods, with 4 properties (including their type, documentation and other data), and the class is documented as `Interlayer pagination metadata object`. Also, it has no parents.

## Installation
### Swift Package Manager dependency

```swift
.package(
    name: "Synopsis"
    url: "https://github.com/Incetro/synopsis",
    .branch("main")
)
```

## Usage

* [Synopsis struct](#synopsis-struct)
    - [Classes, structuress and protocols](#classes)
    - [Enums](#enums)
    - [Methods and functions](#functions)
    - [Properties](#properties)
    - [Annotations](#annotations)
    - [Property types, argument types, return types](#types)
    - [Declaration](#declarations)
    - [Nested parsing](#nested)
* [Code generation, templates and versing](#versing)

### Synopsis struct

`Synopsis` structure is your starting point. This class provides you all available specifications with a `specifications(from:)` method that accepts a list of file URLs
of your `*.swift` source code files.

```swift
let files: [URL] = getFiles()
let result = Synopsis.default.specifications(from: files)
```

Initialized `result.specifications` structure has properties `classes`, `structures`, `protocols`, `enums`, `extensions` and `functions` containing descirpitons
of found classes, structs, protocols, enums, extensions and high-level free functions respectively. Also  `Specifications` structure contains `consolidated` computed properties for `classes`, `structures`, `protocols`, `enums` where they joined with their external extensions.
You may also examine `result.errors` property with a list of problems occured during the compilation process.

```swift
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
    public var consolidatedEnums: [EnumSpecification: [ExtensionSpecification]] { get }

    /// Protocols which are consolidated with their extensions
    public var consolidatedProtocols: [ProtocolSpecification: [ExtensionSpecification]] { get }

    /// Structures which are consolidated with their extensions
    public var consolidatedStructures: [StructureSpecification: [ExtensionSpecification]] { get }

    /// Classes which are consolidated with their extensions
    public var consolidatedClasses: [ClassSpecification: [ExtensionSpecification]] { get }
}
```

<a name="classes" />

### Classes, structuress and protocols

Meta-information about found classes, structs and protocols is organized as `ClassSpecification`, `StructSpecification`, `ExtensionSpecification`or `ProtocolSpecification` structs respectively. Each of these implements an `ExtensibleSpecification` protocol.

```swift
struct ClassSpecification:     ExtensibleSpecification {}
struct StructSpecification:    ExtensibleSpecification {}
struct ProtocolSpecification:  ExtensibleSpecification {}
struct ExtensionSpecification: ExtensibleSpecification {}
```

#### Extensible

```swift
// MARK: - ExtensibleSpecification

/// Basically, protocols, structs and classes.
public protocol ExtensibleSpecification: Specification, Equatable, CustomDebugStringConvertible {

    // MARK: - Properties

    /// Documentation comment above the extensible
    var comment: String? { get }

    /// Annotations are located inside the comment
    var annotations: [AnnotationSpecification] { get }

    /// Declaration
    var declaration: Declaration { get }

    /// Access visibility
    var accessibility: AccessibilitySpecification { get }

    /// Some atrributes (like `final` keyword)
    var attributes: [AttributeSpecification] { get }

    /// Name
    var name: String { get }

    /// Inherited types: parent class/classes, protocols etc.
    var inheritedTypes: [String] { get }

    /// List of properties
    var properties: [PropertySpecification] { get }

    /// List of initializers
    var initializers: [MethodSpecification] { get }

    /// List of methods
    var methods: [MethodSpecification] { get }
}
```

Extensibles (read like «classes», «structs», «extensions» or «protocols») include

* `comment` — an optional documentation above the extensible.
* `annotations` — a list of `Annotation` instances parsed from the `comment`; see [Annotation](#annotation) for more details.
* `declaration` — an information, where this current extensible could be found (file, line number, column number etc.); see [Declaration](#declarations) for more details.
* `accessibility` — an `enum` of `private`, `internal`, `public` and `open`.
* `attributes` — an `enum` of `final`, `mutating`, `override`, `discardableResult`, `indirect` etc.
* `name` — an extensible name.
* `inheritedTypes` — a list of all parents, if any.
* `properties` — a list of all properties; see [Property](#properties) for more details.
* `initializers` — a list of initializers; see [Methods and functions](#functions) for more details.
* `methods` — a list of methods, including initializers; see [Methods and functions](#functions) for more details.

There's also a special computed property `verse: String`, which allows to obtain the `Extensible` as a source code.
This is a convenient way of composing new utility classes, see [Code generation, templates and versing](#versing) for more information.

All extensibles support `Equatable` and `CustomDebugStringConvertible` protocols, and extend `Sequence` with
`subscript(name:)` and `contains(name:)` methods.

```swift
// MARK: - Sequence

extension Sequence where Iterator.Element: ExtensibleSpecification {

    public subscript(name: String) -> Iterator.Element? {
        first { $0.name == name }
    }

    public func contains(name: String) -> Bool {
        nil != self[name]
    }
}

```

<a name="enums" />

### Enums

```swift
// MARK: - EnumSpecification

public struct EnumSpecification {

    // MARK: - Properties

    /// Enum comment value
    public let comment: String?

    /// Enum annotations which are located inside
    /// the block comment above the enum declaration.
    public let annotations: [AnnotationSpecification]

    /// Enum declaration line
    public let declaration: Declaration

    /// Access visibility
    public let accessibility: AccessibilitySpecification

    /// Method attributes (like `indirect` etc.)
    public let attributes: [AttributeSpecification]

    /// Enum name
    public let name: String

    /// Inherited protocols, classes, structs etc.
    public let inheritedTypes: [String]

    /// Cases
    public let cases: [EnumCaseSpecification]

    /// List of enum properties.
    public let properties: [PropertySpecification]

    /// Enum methods
    public let methods: [MethodSpecification]
}
```

Enum specifications contain almost the same information as the extensibles, but also include a list of cases.

#### Enum cases

```swift
// MARK: - EnumCaseSpecification

public struct EnumCaseSpecification {

    // MARK: - Properties

    /// Documentation comment
    public let comment: String?

    /// Annotations
    public let annotations: [AnnotationSpecification]

    /// Case name
    public let name: String

    /// Enum case arguments
    public let arguments: [ArgumentSpecification]

    /// Raw default value
    public let defaultValue: String?

    /// Declaration line
    public let declaration: Declaration
}
```

All enum cases have `String` names, and declarations. They may also have documentation (with [annotations](#annotation)) and optional `defaultValue: String?`.

You should know, that `defaultValue` is a raw text, which may contain symbols like quotes.

```swift
enum CodingKeys {
    case firstName = "first_name" // defaultValue == "\"first_name\""
}
```

<a name="functions" />

### Methods and functions

```swift
// MARK: - FunctionSpecification

public class FunctionSpecification: Specification, CustomDebugStringConvertible {

    // MARK: - Properties

    /// Documentation comment
    public let comment: String?

    /// Function annotation.
    /// Function annotations are located inside block comment above the declaration.
    public let annotations: [AnnotationSpecification]

    /// Access visibility
    public let accessibility: AccessibilitySpecification

    /// Method attributes (like `override`, `mutating` etc.)
    public let attributes: [AttributeSpecification]

    /// Function name
    ///
    /// Almost like signature, but without argument types
    public let name: String

    /// Function arguments
    public let arguments: [ArgumentSpecification]

    /// Return type
    public let returnType: TypeSpecification?

    /// Function declaration line
    public let declaration: Declaration

    /// Kind
    public let kind: Kind

    /// Function body, if available
    public let body: String?

    /// True if we need to indent our parameters comments
    /// by longest parameters string:
    ///
    /// if indentCommentByLongestParameter is true that we'll have:
    /// ```
    /// func obtainUser(
    ///     withFirstName firstName: String, /// first name comment
    ///     secondName: String,              /// first name comment
    ///     age: Int,                        /// first name comment
    ///     id: String                       /// first name comment
    /// )
    /// ```
    ///
    /// Otherwise:
    /// ```
    /// func obtainUser(
    ///     withFirstName firstName: String, /// first name comment
    ///     secondName: String, /// first name comment
    ///     age: Int, /// first name comment
    ///     id: String /// first name comment
    /// )
    /// ```
    ///
    public let indentCommentByLongestParameter: Bool = true
}
```

**Synopsis** assumes that method is a function subclass with a couple additional features.

All functions have

* optional documentation;
* [annotations](#annotation);
* accessibility (`private`, `internal`, `public` or `open`);
* name;
* list of arguments (of type `ArgumentSpecification`, [see below](#arguments));
* optional return type (of type `TypeSpecification`, [see below](#types));
* a declaration (of type `Declaration`, [see below](#declarations));
* kind;
* optional body;
* an opportunity to indent arguments comments.

Methods also have some computed properties.

```swift
// MARK: - MethodSpecification

public final class MethodSpecification: FunctionSpecification {

    /// Is it a simple method or an initializer?
    public var isInitializer: Bool {
        name.hasPrefix("init(")
    }

    /// Is it a simple method or an initializer?
    public var isFunction: Bool {
        !isInitializer
    }
}
```

While most of the `FunctionSpecification` properties are self-explanatory, some of them have their own quirks and tricky details behind.
For instance, method names must contain round brackets `()` and are actually a kind of a signature without types, e.g. `myFunction(argument:count:)`.

```swift
func myFunction(arg argument: String) -> Int {}
// this function is named "myFunction(arg:)"
```

Function `kind` could only be `free`, while methods could have a `class`, `static` or `instance` kind.

Methods inside protocols have the same set of properties, but contain no body.
The body itself is a text inside curly brackets `{...}`, but without brackets.

```swift
func topLevelFunction() {
}
// this function body is equal to "\n"
```

<a name="arguments" />

#### Arguments

```swift
// MARK: - ArgumentSpecification

/// Method argument specification
public struct ArgumentSpecification {

    // MARK: - Properties

    /// Argument "external" name used in method calls
    public let name: String

    /// Argument "internal" name used inside method body
    public let bodyName: String

    /// Argument type
    public let type: TypeSpecification

    /// Default value, if any
    public let defaultValue: String?

    /// Argument annotations;
    /// N.B.: arguments only have inline annotations
    public let annotations: [AnnotationSpecification]

    /// Argument declaration
    public let declaration: Declaration? // FIXME: Make mandatory

    /// Inline comment
    public let comment: String?
}
```

Function and method arguments all have external and internal names, a type, an optional `defaultValue`, own optional documentation and [annotations](#annotation).

External `name` is an argument name when the function is called. Internal `bodyName` is used insibe function body. Both are mandatory, though they could be equal.

Argument type is described below, see [TypeSpecification](#types).

<a name="properties" />

### Properties

Properties are represented with a `PropertySpecification` struct.

```swift
// MARK: - PropertySpecification

/// Property specification.
public struct PropertySpecification {

    // MARK: - Properties

    /// Documentation comment
    public let comment: String?

    /// Property annotations
    public let annotations: [AnnotationSpecification]

    /// Access visibility
    public let accessibility: AccessibilitySpecification

    /// DeclarationKind value
    /// Supported kinds:
    ///     `@objc dynamic var`
    ///     `private(set) var`
    ///     `let`
    ///     `var`
    public let declarationKind: DeclarationKind

    /// Property name
    public let name: String

    /// Property type
    public let type: TypeSpecification

    /// Raw default value
    public let defaultValue: String?

    /// Property declaration line
    public let declaration: Declaration

    /// Kind of a property
    public let kind: Kind

    /// Getters, setters, didSetters, willSetters etc.
    public let body: String?

    // MARK: - Kind

    public enum Kind {
        case `class`
        case `static`
        case instance
    }

    // MARK: - DeclarationKind

    public enum DeclarationKind: String {
        case `let` = "let"
        case `var` = "var"
        case privateSet = "private(set) var"
        case objcDynamicVar = "@objc dynamic var "
    }
}
```

Properties could have documentation and [annotations](#annotation). All properties have own `kind` of `class`, `static` or `instance`. Also they have declaration kind which can help you with your more accurate analysis.
All properties have names, accessibility, type (see [TypeSpecification](#types)), a raw `defaultValue: String?`
and a `declaration: Declaration`.

Computed properties could also have a `body`, like functions. The body itself is a text inside curly brackets `{...}`,
but without brackets.

<a name="annotations" />

### Annotations

```swift
// MARK: - AnnotationSpecification

/// Meta-information about classes, protocols, structures,
/// properties, methods and method arguments located in the nearby
/// documentation comments
public struct AnnotationSpecification {

    // MARK: - Properties

    /// Name of the annotation; doesn't include "@" symbol
    public let name: String

    /// Value of the annotation; optional, contains
    /// first word after annotation name, if any.
    ///
    /// Inline annotations may be divided by semicolon,
    /// which may go immediately after annotation name
    /// in case annotation doesn't have any value.
    public let value: String?

    /// Annotation declaration
    public let declaration: Declaration?]
}
```

Extensibles, enums, functions, methods and properties are all allowed to have documentation.

**Synopsis** parses documentation in order to gather special annotation elements with important meta-information.
These annotations resemble Java annotations, but lack their compile-time checks.

All annotations are required to have a name. Annotations can also contain an optional `String` value.

Annotations are recognized by the `@` symbol, for instance:

```swift
/// @model
class Model {}
```

> N.B. Documentation comment syntax is inherited from the Swift compiler, and for now supports block comments and triple slash comments.
> Method or function arguments usually contain documentation in the nearby inline comments, see below.

Use line breaks or semicolons `;` to divide separate annotations:

```swift
/// @annotation1
/// @annotation2; @annotation3
/// @annotation4 value1
/// @annotation5 value2; @annotation5 value3
/// @anontation6; @annotation7 value4
```

Keep annotated function or method arguments on their own separate lines for readability:

```swift
func doSomething(
    with argument: String,    /// @annotation1
    or argument2: Int,        /// @annotation2 value1; @annotation3 value2
    finally argument3: Double /// @annotation4; annotation5 value3
) -> Int
```

Though it is not prohibited to have annotations above arguments:

```swift
func doSomething(
    /// @annotation1
    with argument: String,
    /// @annotation2 value1; @annotation3 value2
    or argument2: Int,
    /// @annotation4; annotation5 value3
    finally argument3: Double
) -> Int
```

<a name="types" />

### Types

Property types, argument types, function return types are represented with a `TypeSpecififcation` enum with cases:

* `boolean`
* `integer`
* `floatingPoint`
* `doublePrecision`
* `string`
* `date`
* `data`
* `optional(wrapped: TypeSpecification)`
* `object(name: String)`
* `array(element: TypeSpecification)`
* `map(key: TypeSpecification, value: TypeSpecification)`
* `generic(name: String, constraints: [TypeSpecification])`

While some of these cases are self-explanatory, others need additional clarification.

`integer` type for now has a limitation, as it represents all `Int` types like `Int16`, `Int32` etc. This means **Synopsis** won't let you determine the `Int` size.

`optional` type contains a wrapped `TypeSpecification` for the actual value type. Same happens for arrays, maps and generics.

All object types except for `Data`, `Date`, `NSData` and `NSDate` are represented with an `object(name: String)` case. So, while `CGRect` is a struct, `Synopsis` will still thinks it is an `object("CGRect")`.

<a name="declarations" />

### Decalration

```swift
// MARK: - Declaration

/// Source code element declaration.
/// Includes absolute file path, line number,
/// column number, offset and raw declaration text itself.
public struct Declaration {

    // MARK: - Properties

    /// File, where statement is declared
    public let filePath: URL

    /// Parsed condensed declaration
    public let rawText: String?

    /// How many characters to skip
    public let offset: Int

    /// Calculated line number
    public let lineNumber: Int

    /// Calculated column number
    public let columnNumber: Int
}
```

Classes, structs, protocols, properties, methods etc. — almost all detected source code elements have a `declaration: Declaration` property.

`Declaration` structure encapsulates several properties:

* filePath — a URL to the end file, where the source code element was detected;
* rawText — a raw line, which was parsed in order to detect source code element;
* offset — a numer of symbols from the beginning of file to the detected source code element;
* lineNumber — self-explanatory;
* columnNumber — self-explanatory; starts from 1.

<a name="nested" />

### Nested parsing

`Synopsis` is able to parse your nested instructions like:

```swift

// MARK: - Constants

enum Contants {

    static let newConstant: Double = 0.5

    // MARK: - Network

    enum Network {

        static let timeout: TimeInterval = 20

        // MARK: - Headers

        enum Headers {

            static let headerOS = "iOS"
        }
    }
}

```

Enums, extension, structures, classes and protocols have their nested properties:

```swift
/// Nested enums
public let enums: [EnumSpecification]

/// Nested structs
public let structs: [StructureSpecification]

/// Nested classes
public let classes: [ClassSpecification]

/// Nested protocols
public let protocols: [ProtocolSpecification]
```

So, if you need you will have nested declarations inside your specification.

<a name="versing" />

### Code generation, templates and versing

Each source code element provides a computed `String` property `verse`, which allows to obtain this element's source code.

This source code is composed programmatically, thus it may differ from the by-hand implementation.

This allows to generate new source code by composing, e.g, `ClassSpecification` instances by hand.

Though, each `ClassSpecification ` instance requires a `Declaration`, which contains a `filePath`, `rawText`, `offset` and other properties yet to be defined, because such source code hasn't been generated yet.

This is why `ClassSpecification` and others provide you with a `template(...)` constructor, which replaces declaration with a special mock object.


## Authors

incetro, incetro@ya.ru / andrew@incetro.ru

Inspired by [RedMadRobot synopsis](https://github.com/RedMadRobot/synopsis)
