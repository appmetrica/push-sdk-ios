// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum PushTarget: String {
    case push = "AppMetricaPush"
    case lazy = "AppMetricaPushLazy"
}

enum PushProduct: String, CaseIterable {
    case push = "AppMetricaPush"
    case pushLazy = "AppMetricaPushLazy"

    static var allProducts: [Product] { allCases.map { $0.product } }

    var targets: [PushTarget] {
        switch self {
        case .push: return [.push]
        case .pushLazy: return [.push, .lazy]
        }
    }

    var product: Product { .library(name: rawValue, targets: targets.map { $0.name }) }
}

enum ExternalDependency: String, CaseIterable {
    case appMetrica = "appmetrica-sdk-ios"
    case kiwi = "Kiwi"

    static var allDependecies: [Package.Dependency] { allCases.map { $0.package } }

    var dependency: Target.Dependency {
        switch self {
        case .appMetrica: return .product(name: "AppMetricaCore", package: rawValue)
        case .kiwi: return .byName(name: rawValue)
        }
    }

    var package: Package.Dependency {
        switch self {
        case .appMetrica: return .package(url: "https://github.com/appmetrica/appmetrica-sdk-ios", "5.2.0"..<"6.0.0")
        case .kiwi: return .package(url: "https://github.com/appmetrica/Kiwi", exact: "3.0.1-spm")
        }
    }
}


extension PushTarget {
    var name: String { rawValue }
    var testsName: String { rawValue + "Tests" }
    var path: String { "\(rawValue)/Sources" }
    var testsPath: String { "\(rawValue)/Tests" }
    var dependency: Target.Dependency { .target(name: rawValue) }
}

extension PushTarget {

    var additionalHeaderPaths: Set<String> {
        switch self {
        case .push:
            return [
                ".",
                "include",
                "include/" + name,
                
                "Lazy",
                "Utils",
            ]
        case .lazy:
            return [
                ".",
                "Lazy",
            ]
        }
    }
    
    var testAdditionalHeaderPaths: Set<String> {
        switch self {
        case .push:
            return [
                "Mocks",
                "Utilities",
            ]
        case .lazy:
            return [
                "."
            ]
        }
    }

}

extension PushTarget {

    var headerPaths: Set<String> {
        let commonPaths: Set<String> = [
            ".",
            "include",
            "include/\(name)"
        ]

        return commonPaths.union(additionalHeaderPaths)
    }

    var testsHeaderPaths: Set<String> {
        let commonPaths: Set<String> = [
            "."
        ]

        let moduleHeaderPaths = headerPaths.map { "../Sources/\($0)" }

        return commonPaths.union(testAdditionalHeaderPaths).union(moduleHeaderPaths)
    }
}

// MARK: - Package -
let package = Package(
    name: "AppMetricaPush",
    platforms: [
        .iOS(.v12),
    ],
    products: PushProduct.allProducts,
    dependencies: ExternalDependency.allDependecies,
    targets: [
        .target(
            target: .push,
            externalDependencies: [.appMetrica],
            includePrivacyManifest: false
        ),
        .testTarget(
            target: .push,
            dependencies: [.push],
            externalDependencies: [.kiwi, .appMetrica]
        ),
        
        .target(
            target: .lazy,
            dependencies: [.push],
            externalDependencies: [.appMetrica],
            searchPaths: [
                "../../AppMetricaPush/Sources",
                "../../AppMetricaPush/Sources/Lazy",
            ],
            includePrivacyManifest: false
        ),
        .testTarget(
            target: .lazy,
            dependencies: [.push, .lazy],
            externalDependencies: [.kiwi, .appMetrica],
            searchPaths: [
                "../../AppMetricaPush/Sources",
            ]
        ),
    ]
)


//MARK: - Helpers

extension Target {
    static func target(target: PushTarget,
                       dependencies: [PushTarget] = [],
                       externalDependencies: [ExternalDependency] = [],
                       searchPaths: [String] = [],
                       includePrivacyManifest: Bool = true) -> Target {
        var resources: [Resource] = []
        if includePrivacyManifest {
            resources.append(.copy("Resources/PrivacyInfo.xcprivacy"))
        }

        let resultSearchPath: Set<String> = target.headerPaths.union(searchPaths)

        return .target(
            name: target.name,
            dependencies: dependencies.map { $0.dependency } + externalDependencies.map { $0.dependency },
            path: target.path,
            resources: resources,
            cSettings: resultSearchPath.sorted().map { .headerSearchPath($0) }
        )
    }

    static func testTarget(target: PushTarget,
                           dependencies: [PushTarget] = [],
                           externalDependencies: [ExternalDependency] = [],
                           searchPaths: [String] = [],
                           resources: [Resource]? = nil) -> Target {

        let resultSearchPath: Set<String> = target.testsHeaderPaths.union(searchPaths)

        return .testTarget(
            name: target.testsName,
            dependencies: dependencies.map { $0.dependency } + externalDependencies.map { $0.dependency },
            path: target.testsPath,
            resources: resources,
            cSettings: resultSearchPath.sorted().map { .headerSearchPath($0) }
        )
    }

}
