
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

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible, _ a21: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible, _ a21: HtmlConvertible, _ a22: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible, _ a21: HtmlConvertible, _ a22: HtmlConvertible, _ a23: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible, _ a21: HtmlConvertible, _ a22: HtmlConvertible, _ a23: HtmlConvertible, _ a24: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24])
  }

  convenience init (_ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible, _ a21: HtmlConvertible, _ a22: HtmlConvertible, _ a23: HtmlConvertible, _ a24: HtmlConvertible, _ a25: HtmlConvertible) {
    self.init([:], [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25])
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

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible, _ a21: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible, _ a21: HtmlConvertible, _ a22: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible, _ a21: HtmlConvertible, _ a22: HtmlConvertible, _ a23: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible, _ a21: HtmlConvertible, _ a22: HtmlConvertible, _ a23: HtmlConvertible, _ a24: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24])
  }

  convenience init (_ attrs: Attrs, _ a1: HtmlConvertible, _ a2: HtmlConvertible, _ a3: HtmlConvertible, _ a4: HtmlConvertible, _ a5: HtmlConvertible, _ a6: HtmlConvertible, _ a7: HtmlConvertible, _ a8: HtmlConvertible, _ a9: HtmlConvertible, _ a10: HtmlConvertible, _ a11: HtmlConvertible, _ a12: HtmlConvertible, _ a13: HtmlConvertible, _ a14: HtmlConvertible, _ a15: HtmlConvertible, _ a16: HtmlConvertible, _ a17: HtmlConvertible, _ a18: HtmlConvertible, _ a19: HtmlConvertible, _ a20: HtmlConvertible, _ a21: HtmlConvertible, _ a22: HtmlConvertible, _ a23: HtmlConvertible, _ a24: HtmlConvertible, _ a25: HtmlConvertible) {
    self.init(attrs, [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25])
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

class br: Element {
  override var tagName: String {
    get { return "br" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class b: Element {
  override var tagName: String {
    get { return "b" } set { self.tagName = newValue }
  }
}

class button: Element {
  override var tagName: String {
    get { return "button" } set { self.tagName = newValue }
  }
}

class caption: Element {
  override var tagName: String {
    get { return "caption" } set { self.tagName = newValue }
  }
}

class code: Element {
  override var tagName: String {
    get { return "code" } set { self.tagName = newValue }
  }
}

class div: Element {
  override var tagName: String {
    get { return "div" } set { self.tagName = newValue }
  }
}

class em: Element {
  override var tagName: String {
    get { return "em" } set { self.tagName = newValue }
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

class meta: Element {
  override var tagName: String {
    get { return "meta" } set { self.tagName = newValue }
  }
  override var void: Bool {
    get { return true } set { self.void = newValue }
  }
}

class option: Element {
  override var tagName: String {
    get { return "option" } set { self.tagName = newValue }
  }
}

class ol: Element {
  override var tagName: String {
    get { return "ol" } set { self.tagName = newValue }
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

class p: Element {
  override var tagName: String {
    get { return "p" } set { self.tagName = newValue }
  }
}

class script: Element {
  override var tagName: String {
    get { return "script" } set { self.tagName = newValue }
  }
}

class select: Element {
  override var tagName: String {
    get { return "select" } set { self.tagName = newValue }
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

//
// === END GENERATED CODE ===
//