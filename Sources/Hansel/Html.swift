
import Foundation

//
// Generate html from a Swift enum datastructure
//
// TODO: Ensure HTML and attr values are escaped
// TODO: Generalize, DRY up the madness
// TODO: Figure out how to stop compiler from crashing from variadic
// init overload so that I can replace the code-gen arity madeness
// with variadic initializers

public typealias Attrs = [String: AttrConvertible]

// HELPERS

func indent (level: Int, tabWidth: Int = 2) -> String {
  return String(count: level * tabWidth, repeatedValue: Character(" "))
}

// PROTOCOLS

public protocol AttrConvertible {
  func render () -> String
}

// EXTENSIONS

// Strings wrapped in .Safe won't be escaped
public enum SafeString: HtmlConvertible {
  case Safe (String)
  public func html () -> String {
    switch self {
    case Safe (let str):
      return str
    }
  }
}

extension String: HtmlConvertible {
  public func html () -> String {
    return Belt.escapeHtml(self)
  }
}

extension String: AttrConvertible {
  public func render () -> String {
    return Belt.escapeHtml(self)
  }
}

extension Dictionary: AttrConvertible  {
  public func render () -> String {
    var output = ""
    for (idx, (k, v)) in self.enumerate() {
      output += (idx > 0 ? " " : "") + "\(k):\(v);"
    }
    return output
  }
}

// IMPL

// For custom nodes
//
// Ex:
//     node("el")
//     node("el", "Hello")
//     node("el", ["display": "block"], "Hello")
//
// TODO: Allow user to create void elements
public class node: Element {
  private init (_ tag: String, attrs: Attrs = [:], kids: [HtmlConvertible] = []) {
    super.init(attrs, kids)
    self.tagName = tag
  }

  // node("el")
  convenience init (_ tag: String) {
    self.init(tag)
  }

  // node("el", ["display": "block"])
  convenience init (_ tag: String, _ attrs: Attrs) {
    self.init(tag, attrs: attrs)
  }

  // node("el", [a, b, c])
  convenience init (_ tag: String, _ kids: [HtmlConvertible]) {
    self.init(tag, kids: kids)
  }

  // node("el", [:], [a, b, c])
  convenience init (_ tag: String, _ attrs: Attrs, _ kids: [HtmlConvertible]) {
    self.init(tag, attrs: attrs, kids: kids)
  }
}

public class Element: HtmlConvertible {
  public var attrs: Attrs = [:]
  // void elements have no kids or closing tag
  public var void: Bool = false
  var tagName: String = ""
  var kids: [HtmlConvertible] = []

  // INITIALIZERS

  public init () {}

  public init (_ attrs: Attrs = [:], _ kids: [HtmlConvertible]) {
    self.attrs = attrs
    self.kids = void ? [] : kids
  }

  public convenience init (_ attrs: Attrs) {
    self.init(attrs, [])
  }

  public convenience init (_ kids: [HtmlConvertible]) {
    self.init([:], kids)
  }

  // FIXME: These blow up the compiler.
  // Swift bug? Until I can get variadic initializers to work,
  // I'll generate initializers of every arity.
  //
  //  convenience init (_ attrs: Attrs, _ kids: HtmlConvertible...) {
  //    self.init(attrs, kids)
  //  }
  //
  //  convenience init (_ kids: HtmlConvertible...) {
  //    self.init([:], kids)
  //  }

  // CONFORMANCE

  public func html () -> String {
    var output = ""
    output += "<\(tagName)\(renderAttrs())>"
    for kid in kids {
      output += kid.html()
    }
    if !void {
      output += "</\(tagName)>"
    }
    return output
  }

  func renderAttrs () -> String {
    if attrs.isEmpty { return "" }
    var output = ""
    for (k, v) in attrs {
      output += " \(k)=\"\(v.render())\""
    }
    return output
  }

  //
  // === BEGIN GENERATED CODE ===
  //

  public convenience init (_ a1: HtmlConvertible) {
    self.init([:], [a1])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible) {
    self.init([:], [a1, a2])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible) {
    self.init([:], [a1, a2, a3])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19])
  }

  public convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible) {
    self.init(attrs, [a1])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible) {
    self.init(attrs, [a1, a2])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19])
  }

  public convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20])
  }

  //
  // === END GENERATED CODE ===
  //
}

// TAG GENERATION

//
// === BEGIN GENERATED CODE ===
//

public class a: Element {
  override var tagName: String {
    get { return "a" } set { self.tagName = newValue }
  }
}

public class abbr: Element {
  override var tagName: String {
    get { return "abbr" } set { self.tagName = newValue }
  }
}

public class address: Element {
  override var tagName: String {
    get { return "address" } set { self.tagName = newValue }
  }
}

public class area: Element {
  override var tagName: String {
    get { return "area" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class article: Element {
  override var tagName: String {
    get { return "article" } set { self.tagName = newValue }
  }
}

public class audio: Element {
  override var tagName: String {
    get { return "audio" } set { self.tagName = newValue }
  }
}

public class base: Element {
  override var tagName: String {
    get { return "base" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class blockquote: Element {
  override var tagName: String {
    get { return "blockquote" } set { self.tagName = newValue }
  }
}

public class body: Element {
  override var tagName: String {
    get { return "body" } set { self.tagName = newValue }
  }
}

public class b: Element {
  override var tagName: String {
    get { return "b" } set { self.tagName = newValue }
  }
}

public class bdi: Element {
  override var tagName: String {
    get { return "bdi" } set { self.tagName = newValue }
  }
}

public class bdo: Element {
  override var tagName: String {
    get { return "bdo" } set { self.tagName = newValue }
  }
}

public class br: Element {
  override var tagName: String {
    get { return "br" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class button: Element {
  override var tagName: String {
    get { return "button" } set { self.tagName = newValue }
  }
}

public class canvas: Element {
  override var tagName: String {
    get { return "canvas" } set { self.tagName = newValue }
  }
}

public class caption: Element {
  override var tagName: String {
    get { return "caption" } set { self.tagName = newValue }
  }
}

public class cite: Element {
  override var tagName: String {
    get { return "cite" } set { self.tagName = newValue }
  }
}

public class code: Element {
  override var tagName: String {
    get { return "code" } set { self.tagName = newValue }
  }
}

public class col: Element {
  override var tagName: String {
    get { return "col" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class colgroup: Element {
  override var tagName: String {
    get { return "colgroup" } set { self.tagName = newValue }
  }
}

public class data: Element {
  override var tagName: String {
    get { return "data" } set { self.tagName = newValue }
  }
}

public class datalist: Element {
  override var tagName: String {
    get { return "datalist" } set { self.tagName = newValue }
  }
}

public class del: Element {
  override var tagName: String {
    get { return "del" } set { self.tagName = newValue }
  }
}

public class dfn: Element {
  override var tagName: String {
    get { return "dfn" } set { self.tagName = newValue }
  }
}

public class dd: Element {
  override var tagName: String {
    get { return "dd" } set { self.tagName = newValue }
  }
}

public class details: Element {
  override var tagName: String {
    get { return "details" } set { self.tagName = newValue }
  }
}

public class dialog: Element {
  override var tagName: String {
    get { return "dialog" } set { self.tagName = newValue }
  }
}

public class div: Element {
  override var tagName: String {
    get { return "div" } set { self.tagName = newValue }
  }
}

public class dl: Element {
  override var tagName: String {
    get { return "dl" } set { self.tagName = newValue }
  }
}

public class dt: Element {
  override var tagName: String {
    get { return "dt" } set { self.tagName = newValue }
  }
}

public class element: Element {
  override var tagName: String {
    get { return "element" } set { self.tagName = newValue }
  }
}

public class em: Element {
  override var tagName: String {
    get { return "em" } set { self.tagName = newValue }
  }
}

public class embed: Element {
  override var tagName: String {
    get { return "embed" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class fieldset: Element {
  override var tagName: String {
    get { return "fieldset" } set { self.tagName = newValue }
  }
}

public class figcaption: Element {
  override var tagName: String {
    get { return "figcaption" } set { self.tagName = newValue }
  }
}

public class figure: Element {
  override var tagName: String {
    get { return "figure" } set { self.tagName = newValue }
  }
}

public class footer: Element {
  override var tagName: String {
    get { return "footer" } set { self.tagName = newValue }
  }
}

public class form: Element {
  override var tagName: String {
    get { return "form" } set { self.tagName = newValue }
  }
}

public class h1: Element {
  override var tagName: String {
    get { return "h1" } set { self.tagName = newValue }
  }
}

public class h2: Element {
  override var tagName: String {
    get { return "h2" } set { self.tagName = newValue }
  }
}

public class h3: Element {
  override var tagName: String {
    get { return "h3" } set { self.tagName = newValue }
  }
}

public class h4: Element {
  override var tagName: String {
    get { return "h4" } set { self.tagName = newValue }
  }
}

public class h5: Element {
  override var tagName: String {
    get { return "h5" } set { self.tagName = newValue }
  }
}

public class h6: Element {
  override var tagName: String {
    get { return "h6" } set { self.tagName = newValue }
  }
}

public class head: Element {
  override var tagName: String {
    get { return "head" } set { self.tagName = newValue }
  }
}

public class header: Element {
  override var tagName: String {
    get { return "header" } set { self.tagName = newValue }
  }
}

public class hgroup: Element {
  override var tagName: String {
    get { return "hgroup" } set { self.tagName = newValue }
  }
}

public class hr: Element {
  override var tagName: String {
    get { return "hr" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class html: Element {
  override var tagName: String {
    get { return "html" } set { self.tagName = newValue }
  }
}

public class i: Element {
  override var tagName: String {
    get { return "i" } set { self.tagName = newValue }
  }
}

public class img: Element {
  override var tagName: String {
    get { return "img" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class input: Element {
  override var tagName: String {
    get { return "input" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class ins: Element {
  override var tagName: String {
    get { return "ins" } set { self.tagName = newValue }
  }
}

public class kbd: Element {
  override var tagName: String {
    get { return "kbd" } set { self.tagName = newValue }
  }
}

public class label: Element {
  override var tagName: String {
    get { return "label" } set { self.tagName = newValue }
  }
}

public class legend: Element {
  override var tagName: String {
    get { return "legend" } set { self.tagName = newValue }
  }
}

public class link: Element {
  override var tagName: String {
    get { return "link" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class li: Element {
  override var tagName: String {
    get { return "li" } set { self.tagName = newValue }
  }
}

public class map: Element {
  override var tagName: String {
    get { return "map" } set { self.tagName = newValue }
  }
}

public class mark: Element {
  override var tagName: String {
    get { return "mark" } set { self.tagName = newValue }
  }
}

public class main: Element {
  override var tagName: String {
    get { return "main" } set { self.tagName = newValue }
  }
}

public class menu: Element {
  override var tagName: String {
    get { return "menu" } set { self.tagName = newValue }
  }
}

public class menuitem: Element {
  override var tagName: String {
    get { return "menuitem" } set { self.tagName = newValue }
  }
}

public class meta: Element {
  override var tagName: String {
    get { return "meta" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class meter: Element {
  override var tagName: String {
    get { return "meter" } set { self.tagName = newValue }
  }
}

public class nav: Element {
  override var tagName: String {
    get { return "nav" } set { self.tagName = newValue }
  }
}

public class noscript: Element {
  override var tagName: String {
    get { return "noscript" } set { self.tagName = newValue }
  }
}

public class object: Element {
  override var tagName: String {
    get { return "object" } set { self.tagName = newValue }
  }
}

public class optgroup: Element {
  override var tagName: String {
    get { return "optgroup" } set { self.tagName = newValue }
  }
}

public class option: Element {
  override var tagName: String {
    get { return "option" } set { self.tagName = newValue }
  }
}

public class output: Element {
  override var tagName: String {
    get { return "output" } set { self.tagName = newValue }
  }
}

public class ol: Element {
  override var tagName: String {
    get { return "ol" } set { self.tagName = newValue }
  }
}

public class p: Element {
  override var tagName: String {
    get { return "p" } set { self.tagName = newValue }
  }
}

public class param: Element {
  override var tagName: String {
    get { return "param" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class pre: Element {
  override var tagName: String {
    get { return "pre" } set { self.tagName = newValue }
  }
}

public class progress: Element {
  override var tagName: String {
    get { return "progress" } set { self.tagName = newValue }
  }
}

public class q: Element {
  override var tagName: String {
    get { return "q" } set { self.tagName = newValue }
  }
}

public class s: Element {
  override var tagName: String {
    get { return "s" } set { self.tagName = newValue }
  }
}

public class script: Element {
  override var tagName: String {
    get { return "script" } set { self.tagName = newValue }
  }
}

public class section: Element {
  override var tagName: String {
    get { return "section" } set { self.tagName = newValue }
  }
}

public class select: Element {
  override var tagName: String {
    get { return "select" } set { self.tagName = newValue }
  }
}

public class small: Element {
  override var tagName: String {
    get { return "small" } set { self.tagName = newValue }
  }
}

public class source: Element {
  override var tagName: String {
    get { return "source" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class span: Element {
  override var tagName: String {
    get { return "span" } set { self.tagName = newValue }
  }
}

public class strong: Element {
  override var tagName: String {
    get { return "strong" } set { self.tagName = newValue }
  }
}

public class style: Element {
  override var tagName: String {
    get { return "style" } set { self.tagName = newValue }
  }
}

public class sub: Element {
  override var tagName: String {
    get { return "sub" } set { self.tagName = newValue }
  }
}

public class summary: Element {
  override var tagName: String {
    get { return "summary" } set { self.tagName = newValue }
  }
}

public class sup: Element {
  override var tagName: String {
    get { return "sup" } set { self.tagName = newValue }
  }
}

public class table: Element {
  override var tagName: String {
    get { return "table" } set { self.tagName = newValue }
  }
}

public class td: Element {
  override var tagName: String {
    get { return "td" } set { self.tagName = newValue }
  }
}

public class template: Element {
  override var tagName: String {
    get { return "template" } set { self.tagName = newValue }
  }
}

public class textarea: Element {
  override var tagName: String {
    get { return "textarea" } set { self.tagName = newValue }
  }
}

public class th: Element {
  override var tagName: String {
    get { return "th" } set { self.tagName = newValue }
  }
}

public class tbody: Element {
  override var tagName: String {
    get { return "tbody" } set { self.tagName = newValue }
  }
}

public class thead: Element {
  override var tagName: String {
    get { return "thead" } set { self.tagName = newValue }
  }
}

public class tfoot: Element {
  override var tagName: String {
    get { return "tfoot" } set { self.tagName = newValue }
  }
}

public class title: Element {
  override var tagName: String {
    get { return "title" } set { self.tagName = newValue }
  }
}

public class tr: Element {
  override var tagName: String {
    get { return "tr" } set { self.tagName = newValue }
  }
}

public class track: Element {
  override var tagName: String {
    get { return "track" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

public class ul: Element {
  override var tagName: String {
    get { return "ul" } set { self.tagName = newValue }
  }
}

public class u: Element {
  override var tagName: String {
    get { return "u" } set { self.tagName = newValue }
  }
}

public class video: Element {
  override var tagName: String {
    get { return "video" } set { self.tagName = newValue }
  }
}

public class wbr: Element {
  override var tagName: String {
    get { return "wbr" } set { self.tagName = newValue }
  }
  public override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

//
// === END GENERATED CODE ===
//
