
import Foundation

//
// Utility belt
//

// FUNCTIONAL HELPERS

// f >> g :: f(g(x))
infix operator >> { associativity left }
public func >> <A, B, C>(f: B -> C, g: A -> B) -> A -> C {
  return { x in f(g(x)) }
}

// f << g :: g(f(x))
infix operator << { associativity left }
public func << <A, B, C>(f: A -> B, g: B -> C) -> A -> C {
  return { x in g(f(x)) }
}

public func identity<T> (a: T) -> T { return a }