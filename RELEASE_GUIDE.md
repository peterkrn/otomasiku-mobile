# Otomasiku Mobile — Release Guide

This guide ensures every release build is **consistent, reliable, and clean**.
Follow every step in order. Do not skip.

---

## 1. Naming Convention

| Artifact | Pattern | Example |
|----------|---------|---------|
| AAB file | `otomasiku-v{MAJOR.MINOR.PATCH}-build{BUILD}.aab` | `otomasiku-v1.0.1-build1.aab` |
| Description file | `otomasiku-v{MAJOR.MINOR.PATCH}-build{BUILD}.txt` | `otomasiku-v1.0.1-build1.txt` |

- AAB location: `build/app/outputs/bundle/release/`
- Description location: `build/app/outputs/descriptions/`
- The `-build{N}` suffix is the **build iteration** for that version (resets to 1 for each new version).

---

## 2. Versioning Rules (Critical)

The version in `pubspec.yaml` follows the format:

```
version: {MAJOR.MINOR.PATCH}+{VERSION_CODE}
```

| Part | Meaning | Google Play requirement |
|------|---------|------------------------|
| `MAJOR.MINOR.PATCH` | Semantic version shown to users (`versionName`) | Any value |
| `+VERSION_CODE` | Integer build identifier (`versionCode`) | **Must be monotonically increasing across all uploads. Never reuse or decrement.** |

### How to bump

1. Check the **latest uploaded version code** on Google Play Console (or the last value in this guide's Release Log below).
2. Increment the version code by at least 1.
3. Update `pubspec.yaml`:

```yaml
version: 1.0.1+3
#              ^ versionCode — must be higher than the previous upload
```

### Common mistake (avoid)

Setting `1.0.1+1` when a previous release used `1.0.0+2` — Google Play rejects with:
> *"Version code 1 has already been used. Try another version code."*

The `+1` here means version code 1, which is lower than 2. Always check the last used version code before building.

---

## 3. Signing Key (Never Duplicate)

- The release keystore is at `android/app/upload.jks` (alias: `upload`).
- Credentials are in `android/key.properties` (git-ignored, never commit).
- `android/app/build.gradle.kts` automatically loads `key.properties` and wires the `release` signing config.

**Rules:**
- **NEVER** generate a new keystore for an existing app. A new key means Google Play won't recognize it as the same app — you'd have to create a new listing.
- **NEVER** commit `upload.jks` or `key.properties` to git.
- **Back up** the keystore and passwords securely. If lost, the app cannot be updated on Play Store.
- See `android/KEYSTORE_SETUP.md` for initial setup (only for first-time setup on a new machine).

---

## 4. Pre-Build Checklist

Before building, verify:

- [ ] All code changes are complete and tested locally.
- [ ] `pubspec.yaml` version is updated with a **version code higher than the last upload**.
- [ ] `android/key.properties` exists and points to the correct `upload.jks`.
- [ ] `.env` file has the correct `SUPABASE_URL` and `SUPABASE_ANON_KEY` for the target environment.
- [ ] No debug code, `print()` statements, or test credentials are left in the codebase.

---

## 5. Build Steps

### Prerequisites

- Flutter SDK at `D:\flutter\bin\flutter.bat` (or adjust path accordingly).
- Java JDK (bundled with Android Studio or installed separately).
- Android SDK configured.

### Build the AAB

```powershell
# From the project root (C:\dev\projects\otomasiku-mobile)
& "D:\flutter\bin\flutter.bat" build appbundle --release
```

This produces:
```
build/app/outputs/bundle/release/app-release.aab
```

### Rename the AAB

```powershell
$version = "1.0.1"
$build   = "build1"

Copy-Item `
  -Path "build\app\outputs\bundle\release\app-release.aab" `
  -Destination "build\app\outputs\bundle\release\otomasiku-v${version}-${build}.aab" `
  -Force
```

The original `app-release.aab` is always overwritten by Flutter — the named copy is your archival artifact.

---

## 6. Description / Changelog File

Create a description file at:
```
build/app/outputs/descriptions/otomasiku-v{VERSION}-build{BUILD}.txt
```

### Release Name Convention

Every release has a **Release Name** that follows this strict style:

```
Otomasiku v{VERSION} - {Short Description}
```

Rules:
- Always start with `Otomasiku v{VERSION} - `.
- The `{Short Description}` is a brief, user-facing summary of the primary change (title case, max ~40 chars).
- No jargon, no internal references. Plain language only.

| Example | Good? | Why |
|---------|-------|-----|
| `Otomasiku v1.0.1 - Fixed Session Issue` | Yes | Clear, concise, user-facing |
| `Clean Slate` | No | Missing app name and version |
| `Otomasiku v1.0.1 - Riverpod cache invalidation on auth state change` | No | Internal jargon |
| `Otomasiku v1.0.2 - Added QRIS Payment` | Yes | Clear, concise, user-facing |

### Format

The description file **must** contain the release name on the first line, followed by the changelog, all wrapped in `<en-US>` tags (required by Google Play Console for localized listings):

```text
<en-US>
Otomasiku v{VERSION} - {Short Description}

Version {VERSION} Changelog:
- Change description 1.
- Change description 2.
- Change description 3.
</en-US>
```

### Guidelines

- **Release Name** (first line) summarizes the primary change for this version.
- Each bullet is a **user-facing change** written in plain language.
- One line per bullet — no wrapping, no sub-bullets.
- Be specific but concise: "Fixed X" or "Added Y" or "Improved Z".
- Do not include internal jargon (no "Riverpod", "Supabase vanity subdomain", etc.) — users don't care.
- Do not include infrastructure changes unless they affect the user experience.

---

## 7. Post-Build Verification

1. Verify the AAB exists and is non-empty:
   ```powershell
   Get-Item "build\app\outputs\bundle\release\otomasiku-v${version}-${build}.aab" | Select-Object Name, Length
   ```
   Expected: ~50-60 MB.

2. Verify the description file exists and is wrapped in `<en-US>` tags.

3. Test install the AAB on a device before uploading:
   ```powershell
   # Optional: extract APKS from AAB for local testing
   # (Requires bundletool from Android SDK)
   bundletool build-apks --bundle=otomasiku-v{VERSION}-build{BUILD}.aab --output=test.apks --mode=universal
   bundletool install-apks --apks=test.apks
   ```

---

## 8. Google Play Console Upload

1. Go to Google Play Console → Otomasiku app → Production (or Internal Testing).
2. Create new release.
3. Upload the `.aab` file.
4. Paste the changelog text (inside the `<en-US>` tags) into the release notes field.
5. Set the release name using the format from section 6 (e.g., "Otomasiku v1.0.1 - Fixed Session Issue").
6. Review and roll out.

---

## 9. Release Log

| Version | Version Code | Build | Date | AAB File | Release Name | Key Changes |
|---------|-------------|-------|------|----------|-------------|-------------|
| 1.0.0 | 2 | build2 | 2026-07 | otomasiku-v1.0.0-build2.aab | Otomasiku v1.0.0 - Initial Release | First public release |
| 1.0.1 | 3 | build2 | 2026-07-12 | otomasiku-v1.0.1-build2.aab | Otomasiku v1.0.1 - Fixed Session Issue | Session cleanup, Supabase vanity domain, QRIS payment description |

> **Always update this table after a successful Play Console upload.** The "Version Code" column is the source of truth for determining the next version code — the next release must use a value higher than the last row.

---

## 10. Quick Reference (Copy-Paste Build)

```powershell
# ── CONFIG ──────────────────────────────────────────────
$version     = "1.0.1"    # Semantic version
$build       = "build2"   # Build iteration for this version
$versionCode = 3          # MUST be higher than last row in Release Log
$releaseName = "Otomasiku v1.0.1 - Fixed Session Issue"  # Goes in .txt first line
$flutter     = "D:\flutter\bin\flutter.bat"

# ── 1. Update pubspec.yaml ──────────────────────────────
# Edit pubspec.yaml → version: ${version}+${versionCode}

# ── 2. Build ────────────────────────────────────────────
& $flutter build appbundle --release
Workdir: C:\dev\projects\otomasiku-mobile

# ── 3. Rename AAB ───────────────────────────────────────
Copy-Item `
  -Path "build\app\outputs\bundle\release\app-release.aab" `
  -Destination "build\app\outputs\bundle\release\otomasiku-v${version}-${build}.aab" `
  -Force

# ── 4. Create description file ──────────────────────────
# Create: build\app\outputs\descriptions\otomasiku-v${version}-${build}.txt
# Format:
#   <en-US>
#   ${releaseName}
#
#   Version ${version} Changelog:
#   - Change 1
#   - Change 2
#   </en-US>

# ── 5. Update Release Log in this file ──────────────────
# Add a new row to the table in section 9.
```