import PackageDescription

let package = Package(
  name: "Hansel",
  dependencies: [
    .Package(
      url: "https://github.com/kylef/PathKit",
      majorVersion: 0,
      minor: 7
    ),
    .Package(
      url: "https://github.com/czechboy0/Jay.git", 
      majorVersion: 1,
      minor: 0
    ),
    .Package(
      url: "https://github.com/Zewo/POSIX.git",
      majorVersion: 0,
      minor: 14 
    ),
    .Package(
      url: "https://github.com/kylef/Commander.git", 
      majorVersion: 0, 
      minor: 5
    )
  ]
)
