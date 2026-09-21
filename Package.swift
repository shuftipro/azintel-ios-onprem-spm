// swift-tools-version:5.3
import PackageDescription

// AZIntel iOS On-Prem SDK — Swift Package Manager distribution.
//
// The binary module is `ShuftiPro` (see ShuftiPro.xcframework), so client apps
// integrate the product below and then `import ShuftiPro`.
//
// This on-prem ("Onsite") framework is fully self-contained: all image assets
// are embedded in ShuftiPro.framework/Assets.car and resolved at runtime via the
// framework's own bundle. Unlike the public SDK, it therefore needs NO separate
// resource target (no PackageDependencies / Media.xcassets).
//
// Distribution: remote binary target. The XCFramework is shipped as a zip
// attached to a GitHub Release; SPM downloads and verifies it against the
// checksum. To publish a new version, bump `version` and `checksumValue`
// together — see RELEASING.md.

let frameworkRepo = "azintel-ios-onprem-spm"
let version = "1.0.1"
let frameworkZip = "ShuftiPro.xcframework.zip"
let checksumValue = "693ef709e0a1eae2f460b3b6d2c1ac2ee149c7326cfb40a8a7e44ea24200b501"

let package = Package(
    name: "azintel-ios-onprem-spm",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ShuftiPro",
            targets: ["ShuftiPro"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "ShuftiPro",
            url: "https://github.com/shuftipro/\(frameworkRepo)/releases/download/\(version)/\(frameworkZip)",
            checksum: checksumValue
        )
    ]
)
