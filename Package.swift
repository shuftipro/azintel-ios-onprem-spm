// swift-tools-version:5.9
import PackageDescription

let frameworkRepo = "azintel-ios-onprem-spm"
let version = "1.0.4"
let frameworkZip = "ShuftiPro.xcframework.zip"
let checksumValue = "86d1bb68f45c7447a3a29c037e1f3e73f670a377ffd6f0c8e3ef73f0a283fdfd"

let package = Package(
    name: "azintel-ios-onprem-spm",
    platforms: [
        .iOS(.v15)
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
