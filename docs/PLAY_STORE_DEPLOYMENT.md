# Guide: Deploying the .aab to Google Play Store

This document describes how to deploy the generated `app-release.aab` package to the Google Play Store for the `otomasiku-mobile` application.

## Prerequisites

1. **Google Play Console Developer Account**: Access to your Play Console account is required.
2. **Keystore Signing**: The `.aab` file must be compiled using your production release signing key (keystore), configured in `android/key.properties` and your release buildType.
3. **App Privacy Policy URL**: Google requires a public privacy policy page. In our application, this is configured as:
   `https://otomasiku.com/privacy-policy/index.html` (refer to [.env](file:///C:/dev/projects/otomasiku-mobile/.env)).
4. **App Credentials for Reviewers**: If your app requires authentication (Supabase PKCE login), you must prepare a test email and password for Google's app reviewers.

---

## Step-by-Step Deployment Steps

### Step 1: Create or Select the App in Play Console
1. Log in to the [Google Play Console](https://play.google.com/console).
2. Click **Create app** if you are deploying for the first time, or select `Otomasiku` from your app list.
3. Fill in the default language, app type (App), pricing (Free), and accept the developer declarations.

### Step 2: Complete the Initial App Setup Checklist
On the dashboard, complete the required developer questionnaires:
* **App Access**: Since the app requires authentication, provide the mock/test account email and password under "All or some functionality is restricted".
* **Content Ratings**: Complete the questionnaire to get an official rating.
* **Privacy Policy**: Enter the URL `https://otomasiku.com/privacy-policy/index.html`.
* **Data Safety**: Complete the safety form. Note that this app uses Supabase for authentication and stores tokens locally in secure storage; declare that user identifiers (email, profile info) are collected for account management.

### Step 3: Setup App Store Presence
Under **Store presence** > **Main store listing**:
* **App details**: Provide the App Name, Short description, and Full description.
* **Graphics**:
  * **App Icon**: 512x512 px, 32-bit PNG.
  * **Feature Graphic**: 1024x500 px, JPG or 24-bit PNG.
  * **Screenshots**: Upload at least 2 screenshots of the app on a phone layout (9:16 or 16:9 ratio).

### Step 4: Create a Release and Upload the AAB
1. Navigate to **Release** > **Testing** (for Internal/Closed testing) or **Production** in the left navigation sidebar.
2. Click **Create new release**.
3. Under **App bundles**, click **Upload** and select the generated AAB file:
   `build/app/outputs/bundle/release/app-release.aab`
4. Enter a **Release name** and write the **Release notes** (e.g., describing the payment/proof-upload updates).
5. Click **Save** and then **Review release**.

### Step 5: Start Rollout
1. Review any warnings or errors reported by the Console. (Warnings about missing debug symbols are common but can be ignored for rollout unless they block the release).
2. Click **Start rollout to Production** (or Internal testing).
3. The release will enter the **In review** state. Google usually takes anywhere from a few hours to 3-5 days to review new apps or major updates.

---

## Future Automation (Fastlane Setup)
For future automated deployments directly from your CLI or CI pipeline, you can set up [Fastlane](https://fastlane.tools/):
1. Install Fastlane: `gem install fastlane`
2. Initialize inside `./android`: `fastlane init`
3. Download the Google Play API service account JSON key and configure it in your `Appfile`.
4. Run `fastlane supply` to automatically push the `.aab` and store metadata directly to the Play Console tracks.
