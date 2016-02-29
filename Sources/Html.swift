
import Foundation

//
// Generate html from a Swift enum datastructure
//
// TODO: Escape HTML
// TODO: Generalize, DRY up the madness
// TODO: DRY this up if swift ever gets variadic init inheritance

typealias Attrs = [String: AttrConvertible]

// HELPERS

func indent (level: Int, tabWidth: Int = 2) -> String {
  return String(count: level * tabWidth, repeatedValue: Character(" "))
}

// PROTOCOLS

protocol AttrConvertible {
  func render () -> String
}

// EXTENSIONS

// Strings wrapped in .Safe won't be escaped
enum SafeString: HtmlConvertible {
  case Safe (String)
  func html () -> String {
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
  func render () -> String {
    return self
  }
}

extension Dictionary: AttrConvertible  {
  func render () -> String {
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
class node: Element {
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

class Element: HtmlConvertible {
  var attrs: Attrs = [:]
  // void elements have no kids or closing tag
  var void: Bool = false
  var tagName: String = ""
  var kids: [HtmlConvertible] = []

  // INITIALIZERS

  init () {}

  init (_ attrs: Attrs = [:], _ kids: [HtmlConvertible]) {
    self.attrs = attrs
    self.kids = void ? [] : kids
  }

  convenience init (_ attrs: Attrs) {
    self.init(attrs, [])
  }

  convenience init (_ kids: [HtmlConvertible]) {
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

  func html () -> String {
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

  convenience init (_ a1: HtmlConvertible) {
    self.init([:], [a1])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible) {
    self.init([:], [a1, a2])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible) {
    self.init([:], [a1, a2, a3])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible) {
    self.init(attrs, [a1])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible) {
    self.init(attrs, [a1, a2])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible) {
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

class a: Element {
  override var tagName: String {
    get { return "a" } set { self.tagName = newValue }
  }
}

class abbr: Element {
  override var tagName: String {
    get { return "abbr" } set { self.tagName = newValue }
  }
}

class address: Element {
  override var tagName: String {
    get { return "address" } set { self.tagName = newValue }
  }
}

class area: Element {
  override var tagName: String {
    get { return "area" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class article: Element {
  override var tagName: String {
    get { return "article" } set { self.tagName = newValue }
  }
}

class audio: Element {
  override var tagName: String {
    get { return "audio" } set { self.tagName = newValue }
  }
}

class base: Element {
  override var tagName: String {
    get { return "base" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class blockquote: Element {
  override var tagName: String {
    get { return "blockquote" } set { self.tagName = newValue }
  }
}

class body: Element {
  override var tagName: String {
    get { return "body" } set { self.tagName = newValue }
  }
}

class b: Element {
  override var tagName: String {
    get { return "b" } set { self.tagName = newValue }
  }
}

class bdi: Element {
  override var tagName: String {
    get { return "bdi" } set { self.tagName = newValue }
  }
}

class bdo: Element {
  override var tagName: String {
    get { return "bdo" } set { self.tagName = newValue }
  }
}

class br: Element {
  override var tagName: String {
    get { return "br" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class button: Element {
  override var tagName: String {
    get { return "button" } set { self.tagName = newValue }
  }
}

class canvas: Element {
  override var tagName: String {
    get { return "canvas" } set { self.tagName = newValue }
  }
}

class caption: Element {
  override var tagName: String {
    get { return "caption" } set { self.tagName = newValue }
  }
}

class cite: Element {
  override var tagName: String {
    get { return "cite" } set { self.tagName = newValue }
  }
}

class code: Element {
  override var tagName: String {
    get { return "code" } set { self.tagName = newValue }
  }
}

class col: Element {
  override var tagName: String {
    get { return "col" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class colgroup: Element {
  override var tagName: String {
    get { return "colgroup" } set { self.tagName = newValue }
  }
}

class data: Element {
  override var tagName: String {
    get { return "data" } set { self.tagName = newValue }
  }
}

class datalist: Element {
  override var tagName: String {
    get { return "datalist" } set { self.tagName = newValue }
  }
}

class del: Element {
  override var tagName: String {
    get { return "del" } set { self.tagName = newValue }
  }
}

class dfn: Element {
  override var tagName: String {
    get { return "dfn" } set { self.tagName = newValue }
  }
}

class dd: Element {
  override var tagName: String {
    get { return "dd" } set { self.tagName = newValue }
  }
}

class details: Element {
  override var tagName: String {
    get { return "details" } set { self.tagName = newValue }
  }
}

class dialog: Element {
  override var tagName: String {
    get { return "dialog" } set { self.tagName = newValue }
  }
}

class div: Element {
  override var tagName: String {
    get { return "div" } set { self.tagName = newValue }
  }
}

class dl: Element {
  override var tagName: String {
    get { return "dl" } set { self.tagName = newValue }
  }
}

class dt: Element {
  override var tagName: String {
    get { return "dt" } set { self.tagName = newValue }
  }
}

class element: Element {
  override var tagName: String {
    get { return "element" } set { self.tagName = newValue }
  }
}

class em: Element {
  override var tagName: String {
    get { return "em" } set { self.tagName = newValue }
  }
}

class embed: Element {
  override var tagName: String {
    get { return "embed" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class fieldset: Element {
  override var tagName: String {
    get { return "fieldset" } set { self.tagName = newValue }
  }
}

class figcaption: Element {
  override var tagName: String {
    get { return "figcaption" } set { self.tagName = newValue }
  }
}

class figure: Element {
  override var tagName: String {
    get { return "figure" } set { self.tagName = newValue }
  }
}

class footer: Element {
  override var tagName: String {
    get { return "footer" } set { self.tagName = newValue }
  }
}

class form: Element {
  override var tagName: String {
    get { return "form" } set { self.tagName = newValue }
  }
}

class h1: Element {
  override var tagName: String {
    get { return "h1" } set { self.tagName = newValue }
  }
}

class h2: Element {
  override var tagName: String {
    get { return "h2" } set { self.tagName = newValue }
  }
}

class h3: Element {
  override var tagName: String {
    get { return "h3" } set { self.tagName = newValue }
  }
}

class h4: Element {
  override var tagName: String {
    get { return "h4" } set { self.tagName = newValue }
  }
}

class h5: Element {
  override var tagName: String {
    get { return "h5" } set { self.tagName = newValue }
  }
}

class h6: Element {
  override var tagName: String {
    get { return "h6" } set { self.tagName = newValue }
  }
}

class head: Element {
  override var tagName: String {
    get { return "head" } set { self.tagName = newValue }
  }
}

class header: Element {
  override var tagName: String {
    get { return "header" } set { self.tagName = newValue }
  }
}

class hgroup: Element {
  override var tagName: String {
    get { return "hgroup" } set { self.tagName = newValue }
  }
}

class hr: Element {
  override var tagName: String {
    get { return "hr" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class html: Element {
  override var tagName: String {
    get { return "html" } set { self.tagName = newValue }
  }
}

class i: Element {
  override var tagName: String {
    get { return "i" } set { self.tagName = newValue }
  }
}

class img: Element {
  override var tagName: String {
    get { return "img" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class input: Element {
  override var tagName: String {
    get { return "input" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class ins: Element {
  override var tagName: String {
    get { return "ins" } set { self.tagName = newValue }
  }
}

class kbd: Element {
  override var tagName: String {
    get { return "kbd" } set { self.tagName = newValue }
  }
}

class label: Element {
  override var tagName: String {
    get { return "label" } set { self.tagName = newValue }
  }
}

class legend: Element {
  override var tagName: String {
    get { return "legend" } set { self.tagName = newValue }
  }
}

class link: Element {
  override var tagName: String {
    get { return "link" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class li: Element {
  override var tagName: String {
    get { return "li" } set { self.tagName = newValue }
  }
}

class map: Element {
  override var tagName: String {
    get { return "map" } set { self.tagName = newValue }
  }
}

class mark: Element {
  override var tagName: String {
    get { return "mark" } set { self.tagName = newValue }
  }
}

class main: Element {
  override var tagName: String {
    get { return "main" } set { self.tagName = newValue }
  }
}

class menu: Element {
  override var tagName: String {
    get { return "menu" } set { self.tagName = newValue }
  }
}

class menuitem: Element {
  override var tagName: String {
    get { return "menuitem" } set { self.tagName = newValue }
  }
}

class meta: Element {
  override var tagName: String {
    get { return "meta" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class meter: Element {
  override var tagName: String {
    get { return "meter" } set { self.tagName = newValue }
  }
}

class nav: Element {
  override var tagName: String {
    get { return "nav" } set { self.tagName = newValue }
  }
}

class noscript: Element {
  override var tagName: String {
    get { return "noscript" } set { self.tagName = newValue }
  }
}

class object: Element {
  override var tagName: String {
    get { return "object" } set { self.tagName = newValue }
  }
}

class optgroup: Element {
  override var tagName: String {
    get { return "optgroup" } set { self.tagName = newValue }
  }
}

class option: Element {
  override var tagName: String {
    get { return "option" } set { self.tagName = newValue }
  }
}

class output: Element {
  override var tagName: String {
    get { return "output" } set { self.tagName = newValue }
  }
}

class ol: Element {
  override var tagName: String {
    get { return "ol" } set { self.tagName = newValue }
  }
}

class p: Element {
  override var tagName: String {
    get { return "p" } set { self.tagName = newValue }
  }
}

class param: Element {
  override var tagName: String {
    get { return "param" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class pre: Element {
  override var tagName: String {
    get { return "pre" } set { self.tagName = newValue }
  }
}

class progress: Element {
  override var tagName: String {
    get { return "progress" } set { self.tagName = newValue }
  }
}

class q: Element {
  override var tagName: String {
    get { return "q" } set { self.tagName = newValue }
  }
}

class s: Element {
  override var tagName: String {
    get { return "s" } set { self.tagName = newValue }
  }
}

class script: Element {
  override var tagName: String {
    get { return "script" } set { self.tagName = newValue }
  }
}

class section: Element {
  override var tagName: String {
    get { return "section" } set { self.tagName = newValue }
  }
}

class select: Element {
  override var tagName: String {
    get { return "select" } set { self.tagName = newValue }
  }
}

class small: Element {
  override var tagName: String {
    get { return "small" } set { self.tagName = newValue }
  }
}

class source: Element {
  override var tagName: String {
    get { return "source" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class span: Element {
  override var tagName: String {
    get { return "span" } set { self.tagName = newValue }
  }
}

class strong: Element {
  override var tagName: String {
    get { return "strong" } set { self.tagName = newValue }
  }
}

class style: Element {
  override var tagName: String {
    get { return "style" } set { self.tagName = newValue }
  }
}

class sub: Element {
  override var tagName: String {
    get { return "sub" } set { self.tagName = newValue }
  }
}

class summary: Element {
  override var tagName: String {
    get { return "summary" } set { self.tagName = newValue }
  }
}

class sup: Element {
  override var tagName: String {
    get { return "sup" } set { self.tagName = newValue }
  }
}

class table: Element {
  override var tagName: String {
    get { return "table" } set { self.tagName = newValue }
  }
}

class td: Element {
  override var tagName: String {
    get { return "td" } set { self.tagName = newValue }
  }
}

class template: Element {
  override var tagName: String {
    get { return "template" } set { self.tagName = newValue }
  }
}

class textarea: Element {
  override var tagName: String {
    get { return "textarea" } set { self.tagName = newValue }
  }
}

class th: Element {
  override var tagName: String {
    get { return "th" } set { self.tagName = newValue }
  }
}

class tbody: Element {
  override var tagName: String {
    get { return "tbody" } set { self.tagName = newValue }
  }
}

class thead: Element {
  override var tagName: String {
    get { return "thead" } set { self.tagName = newValue }
  }
}

class tfoot: Element {
  override var tagName: String {
    get { return "tfoot" } set { self.tagName = newValue }
  }
}

class title: Element {
  override var tagName: String {
    get { return "title" } set { self.tagName = newValue }
  }
}

class tr: Element {
  override var tagName: String {
    get { return "tr" } set { self.tagName = newValue }
  }
}

class track: Element {
  override var tagName: String {
    get { return "track" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class ul: Element {
  override var tagName: String {
    get { return "ul" } set { self.tagName = newValue }
  }
}

class u: Element {
  override var tagName: String {
    get { return "u" } set { self.tagName = newValue }
  }
}

class video: Element {
  override var tagName: String {
    get { return "video" } set { self.tagName = newValue }
  }
}

class wbr: Element {
  override var tagName: String {
    get { return "wbr" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

//
// === END GENERATED CODE ===
//