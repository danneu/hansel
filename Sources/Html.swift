
import Foundation

//
// Generate html from a Swift enum datastructure
//
// TODO: Make the DSL bearable... this is truly awful
// TODO: Escape HTML
// TODO: Generalize, DRY up the madness

indirect enum Html {
  case Div$ (Attrs, Html)
  case Div (Html)
  case P$ (Attrs, Html)
  case P (Html)
  // General
  case Node$ (String, Attrs, Html)
  case Node (String, Html)
  // Special
  case Spread ([Html])
  case Text (String)
  case None

  typealias Attrs = [String: String?]

  func render () -> String {
    return Html.render(self)
  }

  static func render (node: Html, _ level: Int = 0) -> String {
    switch node {
    // Special
    case None:
      return ""
    case Text (let str):
      return "\n" + renderLevel(level) + Belt.escapeHtml(str) + "\n"
    case Spread (let nodes):
      return nodes.map { node in render(node, level + 1) }.joinWithSeparator("")
    // Tags
    case let Div$ (attrs, node):
      return "\n\(renderLevel(level))<div\(renderAttrs(attrs))>\(render(node, level + 1))\(renderLevel(level))</div>\n"
    case let Div (node):
      return "\n\(renderLevel(level))<div>\(render(node, level + 1))\(renderLevel(level))</div>\n"
    case let P$ (attrs, node):
      return "\n\(renderLevel(level))<p\(renderAttrs(attrs))>\(render(node, level + 1))\(renderLevel(level))</p>\n"
    case let P (node):
      return "\n\(renderLevel(level))<p>\(render(node, level + 1))\(renderLevel(level))</p>\n"
    // General
    case let Node$ (tagName, attrs, node):
      return "\n\(renderLevel(level))<\(tagName)\(renderAttrs(attrs))>\(render(node, level + 1))\(renderLevel(level))</\(tagName)>\n"
    case let Node (tagName, node):
      return "\n\(renderLevel(level))<\(tagName)>\(render(node, level + 1))\(renderLevel(level))</\(tagName)>\n"
    }
  }

  static func renderAttrs (attrs: Attrs) -> String {
    var output = ""
    for (key, val) in attrs {
      if val != nil {
        output += " \(key)=\"\(val!)\""
      }
    }
    return output
  }

  static func renderLevel (level: Int) -> String {
    return String(count: level, repeatedValue: Character(" "))
  }
}