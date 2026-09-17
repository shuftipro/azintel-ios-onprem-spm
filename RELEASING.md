# Releasing a New Version

This guide describes how to publish a new version of the **AZIntel iOS On-Prem SDK**
(module: `ShuftiPro`) distributed via Swift Package Manager.

The package uses a **remote binary target** (`url:` + `checksum:` in `Package.swift`).
That means every release requires three things to stay in sync:

1. A **Git tag** (e.g. `1.0.1`)
2. The **`checksum:`** in `Package.swift` (SHA-256 of the new zip)
3. A **GitHub Release** with `ShuftiPro.xcframework.zip` attached as an asset, at that tag

If any one of these is wrong or missing, clients get a download or checksum error.

---

## Versioning rule (Semantic Versioning)

Use `MAJOR.MINOR.PATCH`:

| Change in the SDK                               | Bump      | Example         |
| ----------------------------------------------- | --------- | --------------- |
| Breaking API change                             | **MAJOR** | `1.4.2 → 2.0.0` |
| New features, backward compatible               | **MINOR** | `1.4.2 → 1.5.0` |
| Bug fixes / internal changes, no API change     | **PATCH** | `1.4.2 → 1.4.3` |

> In the commands below, replace `X.Y.Z` with the new version everywhere it appears.

---

## Step 0 — Prerequisites

- You have push access to `github.com/shuftipro/azintel-ios-onprem-spm`.
- [GitHub CLI](https://cli.github.com) is installed and authenticated:
  ```bash
  gh auth status
  ```
- You have the **new** `ShuftiPro.xcframework` (the updated SDK build) ready on disk.
- Move to the repo root before running anything:
  ```bash
  cd /Users/saadafzaal/Automation/iOS/azintel/azintel-ios-onprem-spm
  ```

---

## Step 1 — Replace the XCFramework with the new build

Drop the new `ShuftiPro.xcframework` into the repo root, replacing the old one.

> The unzipped `ShuftiPro.xcframework/` folder is **not** committed (it is in
> `.gitignore`) — it is only the source you zip from. If you deleted it after the
> last release, just place the new one here now.

```bash
# Remove the previous framework folder if present
rm -rf ShuftiPro.xcframework

# Copy in the new build (adjust the source path)
cp -R /path/to/new/ShuftiPro.xcframework ./ShuftiPro.xcframework
```

Quick sanity check that it is the right framework:

```bash
cat ShuftiPro.xcframework/Info.plist | grep -A1 BinaryPath   # should show ShuftiPro.framework/ShuftiPro
```

---

## Step 2 — Re-create the zip

Delete the old zip and re-zip so that `ShuftiPro.xcframework` sits at the **root**
of the archive (SPM requires this exact layout).

```bash
rm -f ShuftiPro.xcframework.zip

ditto -c -k --sequesterRsrc --keepParent ShuftiPro.xcframework ShuftiPro.xcframework.zip
```

Verify the archive layout (the first entries should be `ShuftiPro.xcframework/...`):

```bash
unzip -l ShuftiPro.xcframework.zip | head
```

---

## Step 3 — Compute the new checksum

```bash
swift package compute-checksum ShuftiPro.xcframework.zip
```

Copy the printed 64-character hash — you need it in the next step.

---

## Step 4 — Update `Package.swift`

Open `Package.swift` and update the **two constants** near the top. They must
always change together (the `url:` is built from `version`):

```swift
let version = "X.Y.Z"                                   // <- new tag
let checksumValue = "<paste-the-new-checksum-from-step-3>"  // <- hash from Step 3
```

You do **not** edit the `url:` line — it is composed from `version` automatically.

Validate the manifest still parses:

```bash
swift package dump-package >/dev/null && echo "Package.swift OK"
```

---

## Step 5 — Commit the changes

```bash
git add Package.swift ShuftiPro.xcframework.zip
git commit -m "Release X.Y.Z"
git push origin main
```

---

## Step 6 — Create and push the tag

The tag **must** exactly match the version in the `url:` from Step 4.

```bash
git tag X.Y.Z
git push origin X.Y.Z
```

---

## Step 7 — Publish the GitHub Release with the zip asset

```bash
gh release create X.Y.Z ShuftiPro.xcframework.zip \
    --title "X.Y.Z" \
    --notes "AZIntel iOS On-Prem SDK X.Y.Z"
```

> The uploaded filename must be exactly **`ShuftiPro.xcframework.zip`**, matching
> the `url:` in `Package.swift`.

Publish this release **immediately after** pushing the tag — until the asset is
uploaded, the `url:` does not resolve and clients will get a download error.

---

## Step 8 — Verify the release is live

Check that the asset URL returns `HTTP 200` (this is the exact URL SPM downloads):

```bash
curl -sIL https://github.com/shuftipro/azintel-ios-onprem-spm/releases/download/X.Y.Z/ShuftiPro.xcframework.zip | grep -i "^HTTP"
```

Then confirm a clean resolve from a scratch checkout (optional but recommended):

```bash
cd /tmp
rm -rf spm-verify && mkdir spm-verify && cd spm-verify
cat > Package.swift <<EOF
// swift-tools-version:5.9
import PackageDescription
let package = Package(
    name: "spm-verify",
    platforms: [.iOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/shuftipro/azintel-ios-onprem-spm", exact: "X.Y.Z")
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "ShuftiPro", package: "azintel-ios-onprem-spm")
        ])
    ]
)
EOF
mkdir -p Sources/App && echo "import ShuftiPro" > Sources/App/App.swift
swift package resolve && echo "RESOLVE OK"
```

A successful resolve (no checksum/download error) confirms the release is consumable.

---

## Step 9 — Tell clients to update

Clients bump the version in their dependency rule (or in `Package.swift`):

```swift
.package(url: "https://github.com/shuftipro/azintel-ios-onprem-spm", from: "X.Y.Z")
```

In Xcode: **File → Packages → Update to Latest Package Versions**.

---

## Quick reference (all commands)

Replace `X.Y.Z` with the new version and `/path/to/new` with your build path:

```bash
cd /Users/saadafzaal/Automation/iOS/azintel/azintel-ios-onprem-spm

# 1. Replace framework
rm -rf ShuftiPro.xcframework
cp -R /path/to/new/ShuftiPro.xcframework ./ShuftiPro.xcframework

# 2. Re-zip
rm -f ShuftiPro.xcframework.zip
ditto -c -k --sequesterRsrc --keepParent ShuftiPro.xcframework ShuftiPro.xcframework.zip

# 3. Checksum (copy the output)
swift package compute-checksum ShuftiPro.xcframework.zip

# 4. Edit Package.swift -> set `version` = "X.Y.Z" and `checksumValue` = <hash>


# 5. Commit
git add Package.swift ShuftiPro.xcframework.zip
git commit -m "Release X.Y.Z"
git push origin main

# 6. Tag
git tag X.Y.Z
git push origin X.Y.Z

# 7. Release + upload asset
gh release create X.Y.Z ShuftiPro.xcframework.zip --title "X.Y.Z" --notes "AZIntel iOS On-Prem SDK X.Y.Z"

# 8. Verify
curl -sIL https://github.com/shuftipro/azintel-ios-onprem-spm/releases/download/X.Y.Z/ShuftiPro.xcframework.zip | grep -i "^HTTP"
```

---

## Troubleshooting

| Symptom                                                        | Cause / Fix                                                                                     |
| ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `checksum of downloaded artifact ... does not match`          | The uploaded zip differs from the one you ran `compute-checksum` on. Re-zip, recompute, update `Package.swift`, re-release. |
| `failed downloading ... 404`                                  | Asset not uploaded, wrong filename, or the tag in `url:` doesn't match the release tag.         |
| Xcode keeps using the old version                             | **File → Packages → Reset Package Caches**, then update to latest.                              |
| `artifact ... has an invalid or unsupported layout`           | The zip was created without `--keepParent`, so `ShuftiPro.xcframework` is not at the archive root. Re-run the `ditto` command in Step 2. |
