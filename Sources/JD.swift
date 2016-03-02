
import Foundation
import Jay

//
// JSON decoder for Jay's JsonValues
//
// Core abstraction:
// Decoder<T> transforms JsonValue into Result<String, T>
//
//    JD.decode(JD.string, .String("foo")) 
//    => .Ok("foo")
//
//    JD.decode(JD.tuple1("status" => JD.int),
//              json("[{\"status\": 200, \"headers\": [] }]"))
//    => .Ok(200)
//
// A Swift version of Evan Czaplicki's work on Elm.

enum Result <ErrType, OkType> {
  case Err (ErrType)
  case Ok (OkType)

  func toOptional () -> OkType? {
    switch self {
    case .Err (_): return nil
    case .Ok (let v): return v
    }
  }
}

struct DecoderError: ErrorType {
  let message: String

  init (_ message: String) {
    self.message = message
  }
}

public struct Decoder <T> {
  let decode: (_: JsonValue) throws -> T

  init (_ decode: (_: JsonValue) throws -> T) {
    self.decode = decode
  }
}

public struct JD {

  //
  // API ENTRYPOINT
  //

  static func decode <T> (decoder: Decoder<T>, _ value: JsonValue) -> Result<String, T> {
    do {
      return try .Ok(decoder.decode(value))
    } catch let err as DecoderError {
      return .Err(err.message)
    } catch let err {
      return .Err("Unhandled error: \(err)")
    }
  }

  //
  // DECODERS
  //

  static let string: Decoder<String> = Decoder { value in
    guard case let .String(str) = value else {
      throw DecoderError("Expected String but got \(value)")
    }
    return str
  }

  static let int: Decoder<Int> = Decoder { value in
    guard case let .Number(num) = value,
      case let .JsonInt(int) = num else {
        throw DecoderError("Expected Int but got \(value)")
    }
    return int
  }

  static let double: Decoder<Double> = Decoder { value in
    guard case let .Number(num) = value,
      case let .JsonDbl(double) = num else {
        throw DecoderError("Expected Double but got \(value)")
    }
    return double
  }

  static let bool: Decoder<Bool> = Decoder { value in
    guard case let .Boolean(jbool) = value else {
      throw DecoderError("Expected Bool but got \(value)")
    }
    switch jbool {
    case .True: return true
    case .False: return false
    }
  }

  static func null <A> (resultWhenNull: A) -> Decoder<A> {
    return Decoder { value in
      guard case .Null = value else {
        throw DecoderError("Expected Null but got \(value)")
      }
      return resultWhenNull
    }
  }

  // TUPLE

  static func tuple1 <A, Z> (f: A -> Z, _ d1: Decoder<A>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value where arr.count == 1 else {
        throw DecoderError("Expected Tuple of length 1 but got \(value)")
      }
      return f(
        try d1.decode(arr[0])
      )
    }
  }

  static func tuple2 <A, B, Z> (f: (A, B) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value where arr.count == 2 else {
        throw DecoderError("Expected Tuple of length 2 but got \(value)")
      }
      return f(
        try d1.decode(arr[0]),
        try d2.decode(arr[1])
      )
    }
  }

  static func tuple3 <A, B, C, Z> (f: (A, B, C) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value where arr.count == 3 else {
        throw DecoderError("Expected Tuple of length 3 but got \(value)")
      }
      return f(
        try d1.decode(arr[0]),
        try d2.decode(arr[1]),
        try d3.decode(arr[2])
      )
    }
  }

  static func tuple4 <A, B, C, D, Z> (f: (A, B, C, D) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value where arr.count == 4 else {
        throw DecoderError("Expected Tuple of length 4 but got \(value)")
      }
      return f(
        try d1.decode(arr[0]),
        try d2.decode(arr[1]),
        try d3.decode(arr[2]),
        try d4.decode(arr[3])
      )
    }
  }

  static func tuple5 <A, B, C, D, E, Z> (f: (A, B, C, D, E) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value where arr.count == 5 else {
        throw DecoderError("Expected Tuple of length 5 but got \(value)")
      }
      return f(
        try d1.decode(arr[0]),
        try d2.decode(arr[1]),
        try d3.decode(arr[2]),
        try d4.decode(arr[3]),
        try d5.decode(arr[4])
      )
    }
  }

  static func tuple6 <A, B, C, D, E, F, Z> (f: (A, B, C, D, E, F) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value where arr.count == 6 else {
        throw DecoderError("Expected Tuple of length 6 but got \(value)")
      }
      return f(
        try d1.decode(arr[0]),
        try d2.decode(arr[1]),
        try d3.decode(arr[2]),
        try d4.decode(arr[3]),
        try d5.decode(arr[4]),
        try d6.decode(arr[5])
      )
    }
  }

  static func tuple7 <A, B, C, D, E, F, G, Z> (f: (A, B, C, D, E, F, G) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>, _ d7: Decoder<G>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value where arr.count == 7 else {
        throw DecoderError("Expected Tuple of length 7 but got \(value)")
      }
      return f(
        try d1.decode(arr[0]),
        try d2.decode(arr[1]),
        try d3.decode(arr[2]),
        try d4.decode(arr[3]),
        try d5.decode(arr[4]),
        try d6.decode(arr[5]),
        try d7.decode(arr[6])
      )
    }
  }

  static func tuple8 <A, B, C, D, E, F, G, H, Z> (f: (A, B, C, D, E, F, G, H) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>, _ d7: Decoder<G>, _ d8: Decoder<H>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value where arr.count == 8 else {
        throw DecoderError("Expected Tuple of length 8 but got \(value)")
      }
      return f(
        try d1.decode(arr[0]),
        try d2.decode(arr[1]),
        try d3.decode(arr[2]),
        try d4.decode(arr[3]),
        try d5.decode(arr[4]),
        try d6.decode(arr[5]),
        try d7.decode(arr[6]),
        try d8.decode(arr[7])
      )
    }
  }

  static func array <T> (decoder: Decoder<T>) -> Decoder<[T]> {
    return Decoder { value in
      guard case let .Array(arr) = value else {
        throw DecoderError("Expected Array but got \(value)")
      }
      return try arr.map { try decoder.decode($0) }
    }
  }

  static func dict <T> (d1: Decoder<T>) -> Decoder<[String: T]> {
    return Decoder { value in
      guard case let .Object(obj) = value else {
        throw DecoderError("Expected Object but got \(value)")
      }
      var output: [String: T] = [:]
      for (k, v) in obj {
        output[k] = try d1.decode(v)
      }
      return output
    }
  }

  static func get <A> (key: String, _ d1: Decoder<A>) -> Decoder<A> {
    return Decoder { value in
      guard case let .Object(obj) = value,
        let keyVal = obj[key] else {
          throw DecoderError("Expected Object with field \"\(key)\" but got \(value)")
      }
      return try d1.decode(keyVal)
    }
  }

  static func at <A> (keys: [String], _ d1: Decoder<A>) -> Decoder<A> {
    return Array(keys.reverse()).reduce(d1, combine: { $1 => $0 })
  }

  static func object1 <A, Z> (f: (_: A) -> Z, _ d1: Decoder<A>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value)
      )
    }
  }

  static func object2 <A, B, Z> (f: (_: A, _: B) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value),
        try d2.decode(value)
      )
    }
  }

  static func object3 <A, B, C, Z> (f: (_: A, _: B, _: C) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value),
        try d2.decode(value),
        try d3.decode(value)
      )
    }
  }

  static func object4 <A, B, C, D, Z> (f: (_: A, _: B, _: C, _: D) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value),
        try d2.decode(value),
        try d3.decode(value),
        try d4.decode(value)
      )
    }
  }

  static func object5 <A, B, C, D, E, Z> (f: (_: A, _: B, _: C, _: D, _: E) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value),
        try d2.decode(value),
        try d3.decode(value),
        try d4.decode(value),
        try d5.decode(value)
      )
    }
  }

  static func object6 <A, B, C, D, E, F, Z> (f: (_: A, _: B, _: C, _: D, _: E, _: F) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value),
        try d2.decode(value),
        try d3.decode(value),
        try d4.decode(value),
        try d5.decode(value),
        try d6.decode(value)
      )
    }
  }

  static func object7 <A, B, C, D, E, F, G, Z> (f: (_: A, _: B, _: C, _: D, _: E, _: F, _: G) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>, _ d7: Decoder<G>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value),
        try d2.decode(value),
        try d3.decode(value),
        try d4.decode(value),
        try d5.decode(value),
        try d6.decode(value),
        try d7.decode(value)
      )
    }
  }

  static func object8 <A, B, C, D, E, F, G, H, Z> (f: (_: A, _: B, _: C, _: D, _: E, _: F, _: G, _: H) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>, _ d7: Decoder<G>, _ d8: Decoder<H>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value),
        try d2.decode(value),
        try d3.decode(value),
        try d4.decode(value),
        try d5.decode(value),
        try d6.decode(value),
        try d7.decode(value),
        try d8.decode(value)
      )
    }
  }

  static func optional <A> (d1: Decoder<A>) -> Decoder<A?> {
    return Decoder { value in
      do {
        return try d1.decode(value)
      } catch {
        return nil
      }
    }
  }

  static func oneOf <A> (ds: [Decoder<A>]) -> Decoder<A> {
    return Decoder { value in
      var errors: [ErrorType] = []
      for d in ds {
        do {
          return try d.decode(value)
        } catch let err {
          errors.append(err)
        }
      }
      throw DecoderError("Expected to find \(errors)")
    }
  }

  static func map <A, Z> (f: (_: A) -> Z, _ d1: Decoder<A>) -> Decoder<Z> {
    return object1(f, d1)
  }

  static func fail (message: String) -> Decoder<Any> {
    return Decoder { _ in throw DecoderError(message) }
  }

  static func succeed <A> (constant: A) -> Decoder<A> {
    return Decoder { _ in return constant }
  }

  static func andThen <A, B> (d1: Decoder<A>, _ f: A -> Decoder<B>) -> Decoder<B> {
    return Decoder { value in
      let result = try d1.decode(value)
      return try f(result).decode(value)
    }
  }

  static let value = Decoder<JsonValue>.self

  static func custom <A, B> (d1: Decoder<A>, _ f: A -> Result<String, B>) -> Decoder<B> {
    return Decoder { value in
      let result = f(try d1.decode(value))
      switch result {
      case .Err (let message): throw DecoderError("Custom decoder failed: \(message)")
      case .Ok (let b): return b
      }
    }
  }
}

//
// `=>` OPERATOR
//

infix operator => { associativity left }

// Ex: "uname" => JD.string
public func => <A> (key: String, d1: Decoder<A>) -> Decoder<A> {
  return JD.get(key, d1)
}

// Ex: ["user", "uname"] => JD.string
public func => <A> (keys: [String], d1: Decoder<A>) -> Decoder<A> {
  return JD.at(keys, d1)
}
