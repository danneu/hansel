
import Foundation
import PathKit

extension Batteries {
  // maxage is milliseconds
  public static func serveStatic (_ root: String, maxAge: Milliseconds = Milliseconds(0)) -> Middleware {
    return { handler in
      return { request in
        var rootPath = Path(root)
        let relativePath = Path(Belt.drop(1, request.path))

        // Only serve assets to HEAD or GET
        if request.method != .Head && request.method != .Get {
          return try handler(request)
        }

        // containing NULL bytes is malicious
        if Array(request.path.utf8).index(of: 0) != nil {
          return Response(.badRequest).text("Malicious path")
        }

        // relative path should not be absolute
        if relativePath.isAbsolute {
          return Response(.badRequest).text("Malicious path")
        }

        // relative path outside root
        if isUpPath(Path("./" + relativePath.description).normalize().description) {
          return Response(.forbidden)
        }

        // resolve and noramlize the root
        rootPath = Path(rootPath.absolute().description + "/").normalize()

        // resolve the full path
        let fullPath = (rootPath + relativePath).absolute()

        // we can only serve files
        guard fullPath.isFile else {
          return try handler(request)
        }

        // guess the mime-type from the extension
        var type: String? = nil
        if let ext = fullPath.`extension` {
          type = Mime.exts[ext]
        }

        // get the stat info so that the stream is etaggable
        guard let stats = stat(fullPath.description) else {
          return try handler(request)
        }

        return Response()
          .stream(FileStream(fullPath.description,
                             fileSize: stats.fileSize,
                             modifiedAt: stats.modifiedAt),
                  type: type)
          .setHeader("Cache-Control", "public, max-age=\(maxAge)")
      }
    }
  }
}

// HELPERS

// path is tring to hop up hierarchy
// 
// TODO: I tried using the sophisticated regex from resolve-path npm, but
// something was lost in translation when I ported it to Swift and it
// didn't protect the endpoint.
func isUpPath (_ str: String) -> Bool {
  return try! RegExp("\\.{2,}").test(str)
}

// FILESYSTEM STAT

func stat (_ path: String) -> (fileSize: Int, modifiedAt: Date)? {
  guard let attrs = try? FileManager.default.attributesOfItem(atPath: path),
    let modifiedAt = attrs[FileAttributeKey.modificationDate] as? Date,
    let fileSize = attrs[FileAttributeKey.size] as? Int else {
      return nil
  }

  return (fileSize, modifiedAt)
}
