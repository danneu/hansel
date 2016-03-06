
import PackageDescription

let package = Package(
  name: "Hansel",
  targets: [
    Target(name: "Hansel"),
    Target(
      name: "HanselDev",
      dependencies: [.Target(name: "Hansel")]
    )
  ],
  dependencies: [
    // Enable CryptoSwift again once CryptoSwift stable can build, 
    // i.e. once its develop branch is merged into stable master.
    //
    // .Package(
    //   url: "https://github.com/krzyzanowskim/CryptoSwift.git", 
    //   majorVersion: 0
    // ),
    .Package(
      url: "https://github.com/kylef/PathKit",
      majorVersion: 0,
      minor: 6
    ),
    .Package(
      url: "https://github.com/czechboy0/Jay.git", 
      majorVersion: 0,
      minor: 3
    ),
    .Package(
      url: "https://github.com/Zewo/POSIXRegex.git",
      majorVersion: 0,
      minor: 2
    )
  ]
)

// with the new swiftpm we have to force it to create a static lib so that
// we can use it from xcode. this will become unnecessary once official
// xcode+swiftpm support is done.  
// watch progress: https://github.com/apple/swift-package-manager/compare/xcodeproj?expand=1

let lib = Product(
  name: "Hansel", 
  type: .Library(.Dynamic),
  modules: "Hansel"
)
products.append(lib)
