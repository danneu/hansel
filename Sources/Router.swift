
import Foundation

//
// A simple router
//
// Not very robust, yet very string-based. 
//
// TODO: Make it more type-safe
// FIXME: Nasty code
//

typealias Params = [String: String]

public enum Router {
  case Node (String, [Middleware], [Router])
  case Route (Method, Handler)

  func find (method: Method, segments: [String], mws: [Middleware], params: Params, router: Router) -> (Handler, Params)? {
    var params = params // need it mutable

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
      return (middleware(rHandler), params)
    case .Node(let nSeg, let nMws, let branches):
      guard let currSeg = segments.first else {
        return nil
      }

      // if param segment like /:message,
      // then merge in a param: ["message": "foo"]
      if isParamSegment(nSeg) {
        params[getParamKey(nSeg)] = Belt.drop(1, currSeg)
      } else {
        // if not a param segment, fail if current segment does not match node's
        // segment
        if (currSeg != nSeg) {
          return nil
        }
      }

      // traverse branches if any match
      var found: (Handler, Params)? = nil
      for branch in branches {
        if let result = self.find(method, segments: restSegs, mws: mws + nMws, params: params, router: branch) {
          found = result
        }
      }
      return found
    }
  }

  func handler () -> Handler {
    return { request in
      if let (h, params) = self.find(request.method, segments: toSegments(request.url), mws: [], params: Params(), router: self) {
        debugPrint("params:", params)
        return h(request)
      } else {
        return Response(.NotFound)
      }
    }
  }
}

private func isParamSegment (input: String) -> Bool {
  return try! RegExp("^/:").test(input)
}

private func getParamKey (segment: String) -> String {
  return try! RegExp("^/:(.+)$").replace(segment, template: "$1")
}

private func toSegments (url: String) -> [String] {
  var arr = url.characters.split("/").map({ s in "/" + String.init(s) })
  arr.insert("/", atIndex: 0)
  return arr
}

// Until swift gets spread (...) operator at callsite, duplicate
// Middleware.swift's compose function here but tweak it so that
// it handles array args.
//
// I was getting fatal crash with `return compose(mws)`
private func composeArr (mws: [Middleware]) -> Middleware {
  let noop: Middleware = identity // tell swift how to infer
  return mws.reduce(noop, combine: { accum, next in accum << next })
}
