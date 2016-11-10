import Foundation

public typealias Middleware = (@escaping Handler) -> Handler

// TODO: Figure out the annotation necessary to generalize compose into <T>

public func compose (_ mws: Middleware...) -> Middleware {
  let noop: Middleware = { x in x } // tell swift how to infer
  return mws.reduce(noop, { accum, next in accum << next })
}
