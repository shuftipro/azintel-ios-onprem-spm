# AZIntel iOS On-Prem SDK

The **AZIntel iOS On-Prem SDK** is the on-premise distribution of the ShuftiPro
identity-verification SDK, packaged for integration through
**Swift Package Manager (SPM)** as a pre-compiled binary (`XCFramework`).

This repository is maintained separately from the standard/public iOS SDK and
ships only the artifacts required to consume the SDK on-premise. It contains no
source code — the SDK is delivered as a signed binary framework.

> **Module name:** the binary module is **`ShuftiPro`**. After adding the package,
> import it in your code as `import ShuftiPro` (see the example below). "AZIntel"
> is the on-prem distribution brand; the compiled module remains `ShuftiPro`.

---

## Requirements

| Requirement            | Version                                             |
| ---------------------- | --------------------------------------------------- |
| iOS Deployment Target  | **iOS 13.0+**                                        |
| Xcode                  | 15.0+ (Swift tools 5.9+)                             |
| Swift                  | 5.9+                                                 |
| Supported slices       | `ios-arm64` (device), `ios-arm64_x86_64-simulator`  |
| Supported sim archs    | Apple Silicon (`arm64`) and Intel (`x86_64`)        |
| Dependencies           | None (self-contained binary framework)              |

---

## Package / Repository URL

```
https://github.com/shuftipro/azintel-ios-onprem-spm
```

> Replace with your organization's actual URL if this package is mirrored to a
> private host.

---

## Installation (Swift Package Manager)

### Xcode

1. In Xcode, open **File → Add Package Dependencies…**
2. Enter the package URL:
   ```
   https://github.com/shuftipro/azintel-ios-onprem-spm
   ```
3. For **Dependency Rule**, choose **Up to Next Major Version** and enter the
   release you want (e.g. `1.0.0`). You may also pin to an **Exact Version** or a
   specific **branch/commit**.
4. Select the **`ShuftiPro`** library product and add it to your app target.
5. Build. SPM downloads the XCFramework zip from the matching GitHub Release and
   verifies it against the checksum in `Package.swift`.

### Package.swift (for SwiftPM-based projects)

```swift
dependencies: [
    .package(
        url: "https://github.com/shuftipro/azintel-ios-onprem-spm",
        from: "1.0.0"
    )
],
targets: [
    .target(
        name: "YourAppTarget",
        dependencies: [
            .product(name: "ShuftiPro", package: "azintel-ios-onprem-spm")
        ]
    )
]
```

---

## Version / Tag usage

Versions are published as **Git tags** that follow [Semantic Versioning](https://semver.org)
(`MAJOR.MINOR.PATCH`). Each tag has a matching GitHub Release with the
`ShuftiPro.xcframework.zip` asset attached.

| Dependency rule            | `Package.swift`                                   |
| -------------------------- | ------------------------------------------------- |
| Up to next major (default) | `from: "1.0.0"`                                   |
| Exact version              | `exact: "1.0.0"`                                  |
| Range                      | `"1.0.0"..<"2.0.0"`                               |
| Branch (testing only)      | `branch: "main"`                                  |

---

## Basic integration example

```swift
import UIKit
import ShuftiPro   // <-- the SDK module

final class VerificationLauncher {

    func startVerification(from presenter: UIViewController) {
        // Refer to the SDK's API reference for the exact configuration payload,
        // access token retrieval, and delegate/callback contract for your
        // on-prem deployment. The snippet below shows the import + entry point;
        // the concrete API surface is provided in the SDK documentation.

        // Example shape (adapt to your integration guide):
        // ShuftiPro.shared.verify(
        //     config: configuration,
        //     from: presenter
        // ) { result in
        //     switch result {
        //     case .verified:   print("Verification succeeded")
        //     case .cancelled:  print("User cancelled")
        //     case .error(let error): print("Verification error: \(error)")
        //     }
        // }
    }
}
```

> The exact API (initializer, configuration model, and callbacks) is defined by
> the shipped framework. Consult your AZIntel on-prem integration guide for the
> concrete method signatures and required verification parameters.

---

## Required configuration

The SDK uses the device camera (and, depending on the enabled verification
services, the microphone, NFC, and location). Add the corresponding usage
descriptions to your app's `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to capture identity documents and a selfie.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video-based verification.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is required to verify your address.</string>
```

Enable additional capabilities (e.g. **Near Field Communication Tag Reading**
for NFC document scanning) in your target's **Signing & Capabilities** only if
your verification journey uses them.

---

## Release / Versioning process (for maintainers)

The package uses a **remote binary target** (`url:` + `checksum:`). The
`ShuftiPro.xcframework.zip` is **not** served from `main` — it is attached to a
GitHub Release whose tag matches the version in `Package.swift`. To publish a new
version:

1. **Drop in the new XCFramework** and produce the zip (from the repo root):
   ```bash
   # Zip so that ShuftiPro.xcframework is at the archive root (required by SPM)
   ditto -c -k --sequesterRsrc --keepParent ShuftiPro.xcframework ShuftiPro.xcframework.zip
   ```

2. **Compute the checksum:**
   ```bash
   swift package compute-checksum ShuftiPro.xcframework.zip
   ```

3. **Update `Package.swift`** — set both the release tag in `url:` and the new
   `checksum:` value. These must always be changed together.

4. **Commit, tag, and push:**
   ```bash
   git add Package.swift ShuftiPro.xcframework.zip
   git commit -m "Release 1.0.0"
   git tag 1.0.0
   git push origin main --tags
   ```

5. **Create the GitHub Release** for tag `1.0.0` and **upload
   `ShuftiPro.xcframework.zip`** as a release asset, so the `url:` in
   `Package.swift` resolves:
   ```bash
   gh release create 1.0.0 ShuftiPro.xcframework.zip \
       --title "1.0.0" \
       --notes "AZIntel iOS On-Prem SDK 1.0.0"
   ```

> **Ordering note:** the tag's `Package.swift` references the release asset URL,
> and the asset only exists once step 5 completes. Publish the release
> **immediately after** pushing the tag; consumers who resolve before the asset
> is uploaded will get a download error until it is available.

### Alternative: local `path:` binary target

If you prefer a fully self-contained repository (no release assets), commit the
**unzipped** `ShuftiPro.xcframework` and replace the binary target with:

```swift
.binaryTarget(
    name: "ShuftiPro",
    path: "ShuftiPro.xcframework"
)
```

This resolves immediately at any tag without a GitHub Release, at the cost of
storing the (larger) framework in Git history. The remote `url:`/`checksum:`
approach is recommended for external client distribution.

---

## License

Proprietary. Distributed to authorized AZIntel on-prem customers only.
