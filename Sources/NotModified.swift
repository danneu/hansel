
import Foundation

extension Batteries {
  // if etag == true, then middleware will generate and add ETag
  // header to response, else it will only use the last-modified header
  public static func notModified (etag: Bool) -> Middleware {
    return { handler in
      return { request in
        var response = try handler(request)

        // only consider HEAD and GET requests
        guard request.method == .Get || request.method == .Head else {
          return response
        }

        // only consider 200 responses
        guard response.status == .ok else {
          return response
        }

        // add etag header
        if etag {
          response = response.setHeader("ETag", ETag.generate(response.body))
        }

        // add last-modified header if body has that info
        if let body = response.body as? FileStream {
          response = response.setHeader("Last-Modified", HttpDate.toString(body.modifiedAt))
        }

        // only consider stale requests
        if !isCached(request, response) {
          return response
        }

        // tell client that their cache is still valid,
        return Response(.notModified)
      }
    }
  }
}

private func isCached (_ request: Request, _ response: Response) -> Bool {
  return etagsMatch(request, response) || notModifiedSince(request, response)
}

private func notModifiedSince (_ request: Request, _ response: Response) -> Bool {
  // ensure headers exist
  let modifiedAtString = response.getHeader("last-modified")
  let targetString = request.getHeader("if-modified-since")
  guard modifiedAtString != nil && targetString != nil else {
    return false
  }
  // ensure headers parse into dates
  guard let modifiedAt: Date = HttpDate.fromString(modifiedAtString!),
        let target: Date = HttpDate.fromString(targetString!) else {
    return false
  }
  // is client's target newer than when the resource was last modified?
  return modifiedAt.timeIntervalSince1970 <= target.timeIntervalSince1970
}

private func etagsMatch (_ request: Request, _ response: Response) -> Bool {
  guard let etag = response.getHeader("etag"),
        let target = request.getHeader("if-none-match") else {
    return false
  }
  return etag == target
}
