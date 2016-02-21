
import Foundation
import PathKit

internal func wrapServeStatic (root: String) -> Middleware {
  return { handler in
    return { request in
      var rootPath = Path(root)
      let relativePath = Path(drop1(request.path))

      // Only serve assets to HEAD or GET
      if request.method != .Head && request.method != .Get {
        return handler(request)
      }

      // containing NULL bytes is malicious
      if Array(request.path.utf8).indexOf(0) != nil {
        return Response(status: .BadRequest, body: "Malicious path")
      }

      // relative path should not be absolute
      if relativePath.isAbsolute {
        return Response(status: .BadRequest, body: "Malicious path")
      }

      // relative path outside root
      if isUpPath(Path("./" + relativePath.description).normalize().description) {
        return Response(.Forbidden)
      }

      // resolve and noramlize the root
      rootPath = Path(rootPath.absolute().description + "/").normalize()

      // resolve the full path
      let fullPath = (rootPath + relativePath).absolute()

      if (fullPath.isFile) {
        var fileBody: NSData
        do {
          fileBody = try fullPath.read()
        } catch {
          return Response(.Error)
        }

        var bytes = [UInt8](count: fileBody.length, repeatedValue: 0)
        fileBody.getBytes(&bytes, length: fileBody.length)

        if let str = NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding) as? String {
          return Response(str)
        } else {
          // TODO: Support byte array body
          return Response(status: .Error)
        }
      }

      return handler(request)
    }
  }
}

// slice off first char of a string. 
// if string is empty, short-circuits empty string
func drop1 (str: String) -> String {
  if str.isEmpty {
    return str
  }
  return str.substringFromIndex(str.startIndex.advancedBy(1))
}

// path is tring to hop up hierarchy
// 
// TODO: I tried using the sophisticated regex from resolve-path npm, but
// something was lost in translation when I ported it to Swift and it
// didn't protect the endpoint.
func isUpPath (str: String) -> Bool {
  let regex = try! NSRegularExpression(pattern: "\\.{2,}", options: [])

  let match = regex.numberOfMatchesInString(
    str,
    options: [],
    range: NSRange(location: 0, length: str.characters.count)
  )

  return match > 0
}