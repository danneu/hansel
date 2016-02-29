
// 
// Anything that implements HtmlConvertible can be passed
// into the response.html() function
//

public protocol HtmlConvertible {
  func html () -> String
}
