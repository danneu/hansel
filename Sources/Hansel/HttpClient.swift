//
//import Foundation
//
////enum Result <OkType, ErrType> {
////  case Ok (OkType)
////  case Err (ErrType)
////}
//
//struct HttpClient {
//  static func get (url: String, _ cb: Result<Response, String> -> Void) -> Void {
//    let nsurl = NSURL(string: url)!
//    print("[HttpClient] get url", url)
//    let session = NSURLSession.sharedSession()
//
//    let request = NSMutableURLRequest(URL: nsurl)
//    request.HTTPMethod = "GET"
//    //request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
//
//    let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) {
//      data, _nsres, error in
//      guard _nsres != nil && data != nil && error == nil else {
//        return cb(.Err("no response / data? there was an error?"))
//      }
//      guard let nsres = _nsres! as? NSHTTPURLResponse else {
//        return cb(.Err("coerce fail"))
//      }
//      guard let headerDict = nsres.allHeaderFields as? [String: String] else {
//        return cb(.Err("headers failed to coerce"))
//      }
//      let headers: [Header] = headerDict.map { k, v in (k, v) }
//      let status: Status = Status(rawValue: nsres.statusCode)!
//
//      let response = Response(status, headers: headers).text(toUtf8(data!))
//
//      return cb(.Ok(response))
//    }
//    task.resume()
//    print(request)
//    sleep(1)
//    print(request)
//  }
//}
//
//
//
//func toBytes (data: NSData) -> [UInt8] {
//  let count = data.length / sizeof(UInt8)
//  var array = [UInt8](count: count, repeatedValue: 0)
//  data.getBytes(&array, length:count * sizeof(UInt8))
//  return array
//}
//
//func toUtf8 (bytes: [UInt8]) -> String {
//  return NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding) as! String
//}
//func toUtf8 (data: NSData) -> String {
//  return NSString(data: data, encoding: NSUTF8StringEncoding) as! String
//}
//
//
//
//// HttpClient(.Get, "http://example.com")
//
//// HttpClient.send(Request(method: .Get, url: "http://example.com"))
//
//// The session object keeps a strong reference to the delegate until your app
//// exits or explicitly invalidates the session. If you do not invalidate 
//// the session, your app leaks memory until it exits.
//
//// Had to add this to info.plist
//// <key>NSAppTransportSecurity</key>
//// <dict>
////  <key>NSAllowsArbitraryLoads</key> <true/>
////</dict>
////