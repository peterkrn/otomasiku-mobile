# Keystore Setup for Play Store Release

This project requires a signing keystore to produce a release build suitable for the Google Play Store.

## 1. Generate the upload keystore

Run the following command from the **project root** directory:

```bash
keytool -genkey -v -keystore android/app/upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You will be prompted for:

| Prompt | What to enter |
|--------|--------------|
| Keystore password | A strong password (save it securely) |
| Key password for **upload** | Re-enter the same password or a different one |
| First and Last name | Your company or developer name |
| Organizational unit | e.g. `Engineering` |
| Organization | e.g. `PT Otomasiku Nusantara` |
| City | e.g. `Jakarta` |
| State | e.g. `DKI Jakarta` |
| Country code | `ID` |

## 2. Fill in key.properties

Edit `android/key.properties` and replace the placeholder values:

```properties
storeFile=app/upload.jks
storePassword=<the keystore password you entered>
keyAlias=upload
keyPassword=<the key password you entered>
```

## 3. Verify the release build

```bash
cd otomasiku-mobile
flutter build appbundle --release
```

The output AAB will be at `build/app/outputs/bundle/release/app-release.aab`.

## Important

- **Never commit** `upload.jks` or `key.properties` with real passwords to git. Both are in `.gitignore`.
- **Back up** the keystore file and passwords securely. If lost, you cannot update your app on the Play Store.
