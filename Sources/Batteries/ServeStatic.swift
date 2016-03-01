
import Foundation
import PathKit

extension Batteries {
  // maxage is milliseconds
  static func serveStatic (root: String, maxAge: Int = 0) -> Middleware {
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
          return Response(.BadRequest).text("Malicious path")
        }

        // relative path should not be absolute
        if relativePath.isAbsolute {
          return Response(.BadRequest).text("Malicious path")
        }

        // relative path outside root
        if isUpPath(Path("./" + relativePath.description).normalize().description) {
          return Response(.Forbidden)
        }

        // resolve and noramlize the root
        rootPath = Path(rootPath.absolute().description + "/").normalize()

        // resolve the full path
        let fullPath = (rootPath + relativePath).absolute()

        // we can only serve files
        guard fullPath.isFile else {
          return handler(request)
        }

        // guess the mime-type from the extension
        var type: String? = nil
        if let ext = fullPath.`extension` {
          type = Mime.exts[ext]
        }

        // get the stat info so that the stream is etaggable
        guard let stats = stat(fullPath.description) else {
          return handler(request)
        }

        return Response()
          .stream(FileStream(fullPath.description,
                             byteSize: stats.byteSize,
                             modifiedAt: stats.modifiedAt),
                  type: type)
          .setHeader("cache-control", "public, max-age=\(maxAge)")
      }
    }
  }
}

// HELPERS

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
  return try! RegExp("\\.{2,}").test(str)
}

// FILESYSTEM STAT

func stat (path: String) -> (byteSize: Int, modifiedAt: NSDate)? {
  guard let attrs: NSDictionary = try? NSFileManager.defaultManager().attributesOfItemAtPath(path),
    let modifiedAt: NSDate = attrs.fileModificationDate() else {
      return nil
  }

  return (Int(attrs.fileSize()), modifiedAt)
}
