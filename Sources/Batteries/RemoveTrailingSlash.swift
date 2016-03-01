
import Foundation

// Middleware that removes the trailing slash of the url
// if there is one and 301s to the new url.
extension Batteries {
  static let removeTrailingSlash: Middleware = { handler in
    return { request in
      if (hasSlash(request.path)) {
        return Response().redirect(trimSlash(request.path), status: .MovedPermanently)
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