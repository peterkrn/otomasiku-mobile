# Guide: Building the Production Android App Bundle (.aab)

This document outlines the workflow and requirements for building a production-ready Android App Bundle (`.aab`) for the `otomasiku-mobile` marketplace application.

## Prerequisites

Before running the build command, verify that your development environment is correctly set up:

1. **Flutter SDK**: Ensure you are using the correct stable version of Flutter.
2. **Android Command-line Tools**: The modern `cmdline-tools` package must be installed in your Android SDK directory.
3. **Android Licenses**: All licenses must be accepted.

Run the following command to diagnose your setup:
```bash
flutter doctor
```
If you encounter errors about `cmdline-tools` or licensing:
* **Install cmdline-tools**: Download it from the Android Developer site and extract it to your SDK directory under `cmdline-tools/latest/`.
* **Accept Licenses**: Run:
  ```powershell
  flutter doctor --android-licenses
  ```

---

## Step-by-Step Build Process

Follow these steps sequentially to generate a clean production build:

### 1. Clean the Environment Variables
Before packaging, make sure that no sensitive backend-only secrets (such as Azure OpenAI API keys) are bundled inside the `.env` file. 

Open [.env](file:///C:/dev/projects/otomasiku-mobile/.env) and remove or comment out any sensitive values:
```env
# Ensure these are removed/blanked out in client-side .env
AZURE_OPENAI_ENDPOINT=
AZURE_OPENAI_API_VERSION=
AZURE_OPENAI_API_KEY=
AZURE_OPENAI_DEPLOYMENT=
```

### 2. Run Static Analysis
The codebase must be completely clean of any analyzer warnings or errors before bundling. Run the `flutter analyze` command via the RTK token-saving wrapper:
```bash
./rtk.exe flutter analyze
```

### 3. Run the Test Suite
Ensure that all unit and widget tests pass cleanly:
```bash
./rtk.exe flutter test
```

### 4. Compile the App Bundle
Once verification passes, run the build command to generate the release `.aab` package:
```bash
./rtk.exe flutter build appbundle
```

---

## Output Location

Upon successful compilation, the signed App Bundle will be located at:
```
build/app/outputs/bundle/release/app-release.aab
```
This is the file you upload directly to the Google Play Console for release.

---

## Troubleshooting

### Issue: "Release app bundle failed to strip debug symbols from native libraries"
This typically happens when the `cmdline-tools` component of the Android SDK is missing or misconfigured. 
* **Fix**: Ensure that `cmdline-tools` is installed under your Android SDK root at `cmdline-tools/latest/` and that the `ANDROID_HOME` (or `ANDROID_SDK_ROOT`) environment variable points correctly to your SDK path.

### Issue: Unused code/resources in package
Resource shrinking is enabled in [build.gradle.kts](file:///C:/dev/projects/otomasiku-mobile/android/app/build.gradle.kts#L61) via `isShrinkResources = true` and `isMinifyEnabled = true`. If you run into build errors related to missing resources, ensure that dynamic resources are correctly registered in the XML files.
