// swift-tools-version:5.9
import PackageDescription

let frameworkRepo = "azintel-ios-onprem-spm"
let version = "1.0.3"
let frameworkZip = "ShuftiPro.xcframework.zip"
let checksumValue = "5c02405833c357687021e78dfd9c887a5214f7e94e658a665de9cffedb5d745d"

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
