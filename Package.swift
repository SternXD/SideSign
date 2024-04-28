// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "SideSign",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_14)
    ],
    products: [
		// MARK: - SideSign
        .library(
            name: "SideSign",
            targets: ["SideSign"]
        ),

        .library(
            name: "SideSign-Static",
            type: .static,
            targets: ["SideSign"]
        ),

        .library(
            name: "SideSign-Dynamic",
            type: .dynamic,
            targets: ["SideSign"]
        ),

		// MARK: - CoreCrypto
		.library(
			name: "CoreCrypto",
			targets: ["CoreCrypto", "CCoreCrypto"]
		),

		.library(
			name: "CoreCrypto-Static",
			type: .static,
			targets: ["CoreCrypto", "CCoreCrypto"]
		),

		.library(
			name: "CoreCrypto-Dynamic",
			type: .dynamic,
			targets: ["CoreCrypto", "CCoreCrypto"]
		),

		// MARK: - CCoreCrypto
		.library(
			name: "CCoreCrypto",
			targets: ["CCoreCrypto"]
		),

		.library(
			name: "CCoreCrypto-Static",
			type: .static,
			targets: ["CCoreCrypto"]
		),

		.library(
			name: "CCoreCrypto-Dynamic",
			type: .dynamic,
			targets: ["CCoreCrypto"]
		)
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", .upToNextMinor(from: "1.1.180")),
		.package(url: "https://github.com/SideStore/iMobileDevice.swift", .upToNextMinor(from: "1.0.4"))
    ],
    targets: [
        // MARK: - SideSign

        .target(
            name: "SideSign",
            dependencies: [
                "CSideSign"
            ],
            cSettings: [
                .headerSearchPath("../minizip/include"),
                .define("CORECRYPTO_DONOT_USE_TRANSPARENT_UNION=1")
            ]
        ),

		.testTarget(
			name: "SideSignTests",
			dependencies: ["SideSign"]
		),

        .target(
            name: "CSideSign",
            dependencies: [
                "CoreCrypto",
                "ldid",
                "minizip"
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include/"),
                .headerSearchPath("include/SideSign"),
                .headerSearchPath("Capabilities"),
                .headerSearchPath("../ldid"),
                .headerSearchPath("../ldid/include"),
                .headerSearchPath("../minizip/include"),
                .headerSearchPath("../ldid"),
                .define("unix", to: "1"),
            ],
            cxxSettings: [
                .headerSearchPath("include/"),
                .headerSearchPath("include/SideSign"),
                .headerSearchPath("Capabilities"),
                .headerSearchPath("../ldid"),
                .headerSearchPath("../ldid/include"),
                .headerSearchPath("../minizip/include"),
                .headerSearchPath("../ldid"),
                .define("unix", to: "1"),
            ],
            linkerSettings: [
                .linkedFramework("UIKit", .when(platforms: [.iOS])),
                .linkedFramework("Security")
            ]
        ),

        // MARK: - ldid

        .target(
            name: "ldid-core",
            dependencies: [
                "OpenSSL",
				.product(name: "libplist", package: "iMobileDevice.swift")
            ],
            exclude: [
                "ldid.hpp",
                "ldid.cpp",
                "version.sh",
                "COPYING",
                "control.sh",
                "control",
                "ios.sh",
                "make.sh",
                "deb.sh",
                "plist.sh",
            ],
            sources: [
                "lookup2.c",
            ],
            publicHeadersPath: "",
            cSettings: [
            ]
        ),

        .target(
            name: "ldid",
            dependencies: ["ldid-core"],
            sources: [
                "alt_ldid.cpp"
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("../ldid-core"),
            ]
        ),

        // MARK: - CoreCrypto

        .target(
            name: "CCoreCrypto",
            exclude: [
                "Sources/CoreCryptoMacros.swift"
            ],
            cSettings: [
                .headerSearchPath("include/corecrypto"),
                .define("CORECRYPTO_DONOT_USE_TRANSPARENT_UNION=1")
            ]
        ),

        .target(
            name: "CoreCrypto",
            dependencies: ["CCoreCrypto"],
            exclude: [
                "Sources/ccsrp.m"
            ],
            cSettings: [
                .define("CORECRYPTO_DONOT_USE_TRANSPARENT_UNION=1")
            ]
        ),

        // MARK: - minizip

        .target(
            name: "minizip",
            sources: [
                "minizip/zip.c",
                "minizip/unzip.c",
                "minizip/ioapi.c"
            ],
            publicHeadersPath: "include"
		)
    ],

    cLanguageStandard: CLanguageStandard.gnu11,
    cxxLanguageStandard: .cxx14
)
