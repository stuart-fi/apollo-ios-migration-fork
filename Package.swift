// swift-tools-version:6.1

import PackageDescription

let package = Package(
  name: "FiApollo",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "FiApollo", targets: ["FiApollo"]),
    .library(name: "FiApolloAPI", targets: ["FiApolloAPI"]),
    .library(name: "FiApollo-Dynamic", type: .dynamic, targets: ["FiApollo"]),
    .library(name: "FiApolloSQLite", targets: ["FiApolloSQLite"]),
    .library(name: "FiApolloWebSocket", targets: ["FiApolloWebSocket"]),
    .library(name: "ApolloTestSupport", targets: ["FiApolloTestSupport"]),
    .plugin(name: "InstallCLI", targets: ["Install CLI"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "FiApollo",
      dependencies: [
        "FiApolloAPI"
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .target(
      name: "FiApolloAPI",
      dependencies: [],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .target(
      name: "FiApolloSQLite",
      dependencies: [
        "FiApollo",
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .target(
      name: "FiApolloWebSocket",
      dependencies: [
        "FiApollo"
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .target(
      name: "FiApolloTestSupport",
      dependencies: [
        "FiApollo",
        "FiApolloAPI"
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .plugin(
      name: "Install CLI",
      capability: .command(
        intent: .custom(
          verb: "apollo-cli-install",
          description: "Installs the Apollo iOS Command line interface."),
        permissions: [
          .writeToPackageDirectory(reason: "Downloads and unzips the CLI executable into your project directory."),
          .allowNetworkConnections(scope: .all(ports: []), reason: "Downloads the Apollo iOS CLI executable from the GitHub Release.")
        ]),
      dependencies: [],
      path: "Plugins/InstallCLI"
    )
  ],
  swiftLanguageModes: [.v6, .v5]
)
