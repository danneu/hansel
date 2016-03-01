
import Foundation

//
// A simple router
//
// Not very robust, yet very string-based. 
//
// TODO: Make it more type-safe
// FIXME: Nasty code...
//

public enum Router {
  case Node (String, [Router])
  case Route (Method, Handler)
  case NodeM (String, [Middleware], [Router])
  case RouteM (Method, [Middleware], Handler)

  func find (method: Method, segments: [String], mws: [Middleware], params: [String: String], router: Router) -> (Handler, [String: String])? {
    var params = params // need it mutable

    var restSegs: [String]
    if segments.count <= 1 {
      restSegs = []
    } else {
      restSegs = Array(segments[1..<segments.count])
    }

    switch router {
    case let .Route (rMethod, rHandler):
      // fail if we hit a route but still have more segments left to crawl
      if (!segments.isEmpty) { return nil }
      // fail if we don't match
      if (method != rMethod) { return nil }
      let middleware = composeArr(mws)
      return (middleware(rHandler), params)
    case let .RouteM (rMethod, rMws, rHandler):
      // fail if we hit a route but still have more segments left to crawl
      if (!segments.isEmpty) { return nil }
      // fail if we don't match
      if (method != rMethod) { return nil }
      let middleware = composeArr(mws + rMws)
      return (middleware(rHandler), params)
    case let .Node (nSeg, branches):
      guard let currSeg = segments.first else { return nil }
      if isParamSegment(nSeg) {
        params[getParamKey(nSeg)] = Belt.drop(1, currSeg)
      } else if currSeg != nSeg {
        return nil
      }
      // traverse branches if any match
      var found: (Handler, [String: String])? = nil
      for branch in branches {
        if let result = self.find(method, segments: restSegs, mws: mws, params: params, router: branch) {
          found = result
        }
      }
      return found
    case let .NodeM(nSeg, nMws, branches):
      guard let currSeg = segments.first else { return nil }
      if isParamSegment(nSeg) {
        params[getParamKey(nSeg)] = Belt.drop(1, currSeg)
      } else if currSeg != nSeg {
        return nil
      }
      // traverse branches if any match
      var found: (Handler, [String: String])? = nil
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
      if let (h, params) = self.find(request.method, segments: toSegments(request.url), mws: [], params: [String: String](), router: self) {
        return try h(request.setParams(params))
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

// REQUEST PARAM EXTENSION

extension Request {
  var params: [String: String] {
    return getStore("params") as? [String: String] ?? [:]
  }

  private func setParams (params: [String: String]) -> Request {
    return self.setStore("params", params)
  }
}
