
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

public enum Result <ErrType, OkType> {
  case err (ErrType)
  case ok (OkType)

  func toOptional () -> OkType? {
    switch self {
    case .err (_): return nil
    case .ok (let v): return v
    }
  }

  func map <B> (_ f: (OkType) -> B) -> Result<ErrType, B> {
    switch self {
    case .err (let err): return .err(err)
    case .ok (let val): return .ok(f(val))
    }
  }

  func mapError <B> (_ f: (ErrType) -> B) -> Result<B, OkType> {
    switch self {
    case .err (let err): return .err(f(err))
    case .ok (let val): return .ok(val)
    }
  }
}

public struct DecoderError: Error {
  public let message: String

  init (_ message: String) {
    self.message = message
  }
}

public struct Decoder <T> {
  public let decode: (_: JsonValue) throws -> T

  public init (_ decode: (_: JsonValue) throws -> T) {
    self.decode = decode
  }
}

public struct JD {

  //
  // API ENTRYPOINT
  //

  public static func decode <T> (_ decoder: Decoder<T>, _ value: JsonValue) -> Result<String, T> {
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

  // MARK: - Decoders

  public static let string: Decoder<String> = Decoder { value in
    guard case let .String(str) = value else {
      throw DecoderError("Expected String but got \(value)")
    }
    return str
  }

  public static let int: Decoder<Int> = Decoder { value in
    guard case let .Number(num) = value,
      case let .JsonInt(int) = num else {
        throw DecoderError("Expected Int but got \(value)")
    }
    return int
  }

  public static let double: Decoder<Double> = Decoder { value in
    guard case let .Number(num) = value,
      case let .JsonDbl(double) = num else {
        throw DecoderError("Expected Double but got \(value)")
    }
    return double
  }

  public static let bool: Decoder<Bool> = Decoder { value in
    guard case let .Boolean(jbool) = value else {
      throw DecoderError("Expected Bool but got \(value)")
    }
    switch jbool {
    case .True: return true
    case .False: return false
    }
  }

  public static func null <A> (_ resultWhenNull: A) -> Decoder<A> {
    return Decoder { value in
      guard case .Null = value else {
        throw DecoderError("Expected Null but got \(value)")
      }
      return resultWhenNull
    }
  }

  // TUPLE
  //
  // If you don't pass a transformation function into the tuple decoder,
  // then the JSON maps directly onto a Swift tuple. i.e. these are
  // equivalent:
  // 
  //     JD.tuple2({ ($0, $1) }, JD.string, JD.int)
  //     JD.tuple2(JD.string, JD.int)

  public static func tuple1 <A, Z> (_ f: @escaping (A) -> Z, _ d1: Decoder<A>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value, arr.count == 1 else {
        throw DecoderError("Expected Tuple of length 1 but got \(value)")
      }
      return f(
        try d1.decode(arr[0])
      )
    }
  }

  public static func tuple1 <A> (_ d1: Decoder<A>) -> Decoder<(A)> {
    return tuple1({ ($0) }, d1)
  }

  public static func tuple2 <A, B, Z> (_ f: @escaping (A, B) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value, arr.count == 2 else {
        throw DecoderError("Expected Tuple of length 2 but got \(value)")
      }
      return f(
        try d1.decode(arr[0]),
        try d2.decode(arr[1])
      )
    }
  }

  public static func tuple2 <A, B> (_ d1: Decoder<A>, _ d2: Decoder<B>) -> Decoder<(A, B)> {
    return tuple2({ ($0, $1) }, d1, d2)
  }

  public static func tuple3 <A, B, C, Z> (_ f: @escaping (A, B, C) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value, arr.count == 3 else {
        throw DecoderError("Expected Tuple of length 3 but got \(value)")
      }
      return f(
        try d1.decode(arr[0]),
        try d2.decode(arr[1]),
        try d3.decode(arr[2])
      )
    }
  }

  public static func tuple3 <A, B, C> (_ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>) -> Decoder<(A, B, C)> {
    return tuple3({ ($0, $1, $2) }, d1, d2, d3)
  }

  public static func tuple4 <A, B, C, D, Z> (_ f: @escaping (A, B, C, D) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value, arr.count == 4 else {
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

  public static func tuple4 <A, B, C, D> (_ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>) -> Decoder<(A, B, C, D)> {
    return tuple4({ ($0, $1, $2, $3) }, d1, d2, d3, d4)
  }

  public static func tuple5 <A, B, C, D, E, Z> (_ f: @escaping (A, B, C, D, E) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value, arr.count == 5 else {
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

  public static func tuple5 <A, B, C, D, E> (_ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>) -> Decoder<(A, B, C, D, E)> {
    return tuple5({ ($0, $1, $2, $3, $4) }, d1, d2, d3, d4, d5)
  }

  public static func tuple6 <A, B, C, D, E, F, Z> (_ f: @escaping (A, B, C, D, E, F) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value, arr.count == 6 else {
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

  public static func tuple6 <A, B, C, D, E, F> (_ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>) -> Decoder<(A, B, C, D, E, F)> {
    return tuple6({ ($0, $1, $2, $3, $4, $5) }, d1, d2, d3, d4, d5, d6)
  }

  public static func tuple7 <A, B, C, D, E, F, G, Z> (_ f: @escaping (A, B, C, D, E, F, G) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>, _ d7: Decoder<G>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value, arr.count == 7 else {
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

  public static func tuple7 <A, B, C, D, E, F, G> (_ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>, _ d7: Decoder<G>) -> Decoder<(A, B, C, D, E, F, G)> {
    return tuple7({ ($0, $1, $2, $3, $4, $5, $6) }, d1, d2, d3, d4, d5, d6, d7)
  }

  public static func tuple8 <A, B, C, D, E, F, G, H, Z> (_ f: @escaping (A, B, C, D, E, F, G, H) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>, _ d7: Decoder<G>, _ d8: Decoder<H>) -> Decoder<Z> {
    return Decoder { value in
      guard case let .Array(arr) = value, arr.count == 8 else {
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

  public static func tuple8 <A, B, C, D, E, F, G, H> (_ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>, _ d7: Decoder<G>, _ d8: Decoder<H>) -> Decoder<(A, B, C, D, E, F, G, H)> {
    return tuple8({ ($0, $1, $2, $3, $4, $5, $6, $7) }, d1, d2, d3, d4, d5, d6, d7, d8)
  }

  public static func array <T> (_ decoder: Decoder<T>) -> Decoder<[T]> {
    return Decoder { value in
      guard case let .Array(arr) = value else {
        throw DecoderError("Expected Array but got \(value)")
      }
      return try arr.map { try decoder.decode($0) }
    }
  }

  public static func dict <T> (_ d1: Decoder<T>) -> Decoder<[String: T]> {
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

  public static func get <A> (_ key: String, _ d1: Decoder<A>) -> Decoder<A> {
    return Decoder { value in
      guard case let .Object(obj) = value,
        let keyVal = obj[key] else {
          throw DecoderError("Expected Object with field \"\(key)\" but got \(value)")
      }
      return try d1.decode(keyVal)
    }
  }

  public static func at <A> (_ keys: [String], _ d1: Decoder<A>) -> Decoder<A> {
    return Array(keys.reversed()).reduce(d1, { $1 => $0 })
  }

  public static func object1 <A, Z> (_ f: @escaping (_: A) -> Z, _ d1: Decoder<A>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value)
      )
    }
  }

  public static func object2 <A, B, Z> (_ f: @escaping (_: A, _: B) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value),
        try d2.decode(value)
      )
    }
  }

  public static func object3 <A, B, C, Z> (_ f: @escaping (_: A, _: B, _: C) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value),
        try d2.decode(value),
        try d3.decode(value)
      )
    }
  }

  public static func object4 <A, B, C, D, Z> (_ f: @escaping (_: A, _: B, _: C, _: D) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>) -> Decoder<Z> {
    return Decoder { value in
      return f(
        try d1.decode(value),
        try d2.decode(value),
        try d3.decode(value),
        try d4.decode(value)
      )
    }
  }

  public static func object5 <A, B, C, D, E, Z> (_ f: @escaping (_: A, _: B, _: C, _: D, _: E) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>) -> Decoder<Z> {
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

  public static func object6 <A, B, C, D, E, F, Z> (_ f: @escaping (_: A, _: B, _: C, _: D, _: E, _: F) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>) -> Decoder<Z> {
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

  public static func object7 <A, B, C, D, E, F, G, Z> (_ f: @escaping (_: A, _: B, _: C, _: D, _: E, _: F, _: G) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>, _ d7: Decoder<G>) -> Decoder<Z> {
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

  public static func object8 <A, B, C, D, E, F, G, H, Z> (_ f: @escaping (_: A, _: B, _: C, _: D, _: E, _: F, _: G, _: H) -> Z, _ d1: Decoder<A>, _ d2: Decoder<B>, _ d3: Decoder<C>, _ d4: Decoder<D>, _ d5: Decoder<E>, _ d6: Decoder<F>, _ d7: Decoder<G>, _ d8: Decoder<H>) -> Decoder<Z> {
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

  public static func optional <A> (_ d1: Decoder<A>) -> Decoder<A?> {
    return Decoder { value in
      do {
        return try d1.decode(value)
      } catch {
        return nil
      }
    }
  }

  public static func oneOf <A> (_ ds: [Decoder<A>]) -> Decoder<A> {
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

  public static func map <A, Z> (_ f: @escaping (_: A) -> Z, _ d1: Decoder<A>) -> Decoder<Z> {
    return object1(f, d1)
  }

  public static func fail (_ message: String) -> Decoder<Any> {
    return Decoder { _ in throw DecoderError(message) }
  }

  public static func succeed <A> (_ constant: A) -> Decoder<A> {
    return Decoder { _ in return constant }
  }

  public static func andThen <A, B> (_ d1: Decoder<A>, _ f: @escaping (A) -> Decoder<B>) -> Decoder<B> {
    return Decoder { value in
      let result = try d1.decode(value)
      return try f(result).decode(value)
    }
  }

  public static let value = Decoder<JsonValue>.self

  public static func custom <A, B> (_ d1: Decoder<A>, _ f: @escaping (A) -> Result<String, B>) -> Decoder<B> {
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
