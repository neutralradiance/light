// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "Light",
  products: [
    .library(
      name: "Light",
      targets: ["Light"]
    )
  ],
  targets: [
    .target(name: "Light")
  ]
)
