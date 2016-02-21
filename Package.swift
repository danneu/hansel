
import PackageDescription

let package = Package(
  name: "Hansel",
  dependencies: [
    .Package(url: "https://github.com/kylef/PathKit", majorVersion: 0)
  ]
)
