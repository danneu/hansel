
import PackageDescription

let package = Package(
  name: "Hansel",
  dependencies: [
    .Package(url: "https://github.com/kylef/PathKit", majorVersion: 0),
    .Package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", majorVersion: 0),
    .Package(url: "https://github.com/czechboy0/Jay.git", majorVersion: 0),
  ]
)
