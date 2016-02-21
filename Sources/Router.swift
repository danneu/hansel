
import Foundation

func toSegments (url: String) -> [String] {
  var arr = url.characters.split("/").map({ s in "/" + String.init(s) })
  arr.insert("/", atIndex: 0)
  return arr
}

// Until swift gets spread (...) operator at callsite, duplicate
// Middleware.swift's compose function here but tweak it so that
// it handles array args.
//
// I was getting fatal crash with `return compose(mws)`
public func composeArr (mws: [Middleware]) -> Middleware {
  let noop: Middleware = identity // tell swift how to infer
  return mws.reduce(noop, combine: { accum, next in accum >> next })
}

// TODO: /:param capture
public enum Router {
  case Node (String, [Middleware], [Router])
  case Route (Method, Handler)

  func find (method: Method, segments: [String], mws: [Middleware], router: Router) -> Handler? {
    var restSegs: [String]
    if segments.count <= 1 {
      restSegs = []
    } else {
      restSegs = Array(segments[1..<segments.count])
    }

    switch router {
    case .Route(let rMethod, let rHandler):
      // fail if we hit a route but still have more segments left to crawl
      if (!segments.isEmpty) {
        return nil
      }
      // fail if we don't match
      if (method != rMethod) {
        return nil
      }
      let middleware = composeArr(mws)
      return middleware(rHandler)
    case .Node(let nSeg, let nMws, let branches):
      let currSeg = segments.first
      if currSeg == nil {
        return nil
      }
      // fail if current segment does not match node's
      if (currSeg != nSeg) {
        return nil
      }
      // traverse branches if any match
      var found: Handler? = nil
      for branch in branches {
        if let h = self.find(method, segments: restSegs, mws: mws + nMws, router: branch) {
          found = h
        }
      }
      return found
    }
  }

  func handler () -> Handler {
    return { request in
      if let h = self.find(request.method, segments: toSegments(request.url), mws: [], router: self) {
        return h(request)
      } else {
        return Response(status: .NotFound)
      }
    }
  }
}
