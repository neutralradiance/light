// swift-tools-version:5.3
import PackageDescription

let package = Package(
	name: "Light",
	platforms: [.iOS(.v12)],
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
