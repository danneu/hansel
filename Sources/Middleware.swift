import Foundation

public typealias Middleware = Handler -> Handler

// TODO: Figure out the annotation necessary to generalize compose into <T>

public func compose (mws: Middleware...) -> Middleware {
  let noop: Middleware = identity // tell swift how to infer
  return mws.reduce(noop, combine: { accum, next in accum >> next })
}
