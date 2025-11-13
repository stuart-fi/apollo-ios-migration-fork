// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Apollo",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5)
  ],
  products: [
    .library(name: "FiApollo", targets: ["FiApollo"]),
    .library(name: "FiApolloAPI", targets: ["FiApolloAPI"]),
    .library(name: "FiApollo-Dynamic", type: .dynamic, targets: ["FiApollo"]),
    .library(name: "FiApolloSQLite", targets: ["FiApolloSQLite"]),
    .library(name: "FiApolloWebSocket", targets: ["FiApolloWebSocket"]),
    .library(name: "FiApolloTestSupport", targets: ["FiApolloTestSupport"]),
    .plugin(name: "InstallCLI", targets: ["Install CLI"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/stephencelis/SQLite.swift.git",
      .upToNextMajor(from: "0.13.1")),
  ],
  targets: [
    .target(
      name: "FiApollo",
      dependencies: [
        "FiApolloAPI"
      ]
    ),
    .target(
      name: "FiApolloAPI",
      dependencies: []
    ),
    .target(
      name: "FiApolloSQLite",
      dependencies: [
        "FiApollo",
        .product(name: "SQLite", package: "SQLite.swift"),
      ]
    ),
    .target(
      name: "FiApolloWebSocket",
      dependencies: [
        "FiApollo"
      ]
    ),
    .target(
      name: "FiApolloTestSupport",
      dependencies: [
        "FiApollo",
        "FiApolloAPI"
      ]
    ),
    .plugin(
      name: "Install CLI",
      capability: .command(
        intent: .custom(
          verb: "apollo-cli-install",
          description: "Installs the Apollo iOS Command line interface."),
        permissions: [
          .writeToPackageDirectory(reason: "Creates a symbolic link to the CLI executable in your project directory."),
        ]),
      dependencies: [],
      path: "Plugins/InstallCLI"
    )
  ]
)
