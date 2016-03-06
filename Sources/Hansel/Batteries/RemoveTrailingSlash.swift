
import Foundation

// Middleware that removes the trailing slash of the url
// if there is one and 301s to the new url.
extension Batteries {
  public static let removeTrailingSlash: Middleware = { handler in
    return { request in
      if (hasSlash(request.path)) {
        let newPath = trimSlash(request.path)
          + (request.nsurl.query == nil ? "" : "?\(request.nsurl.query!)")
        return Response().redirect(newPath, status: .MovedPermanently)
      }
      return try handler(request)
    }
  }
}

private let slashRe = try! RegExp("([^/]+)\\/+$")

private func hasSlash (url: String) -> Bool {
  return slashRe.test(url)
}

private func trimSlash (url: String) -> String {
  return slashRe.replace(url, template: "$1")
}