# هايدرا مايند · HydraMind AI

تطبيق Flutter عربي افتراضياً باتجاه RTL، مع الإنجليزية لغة ثانية، وتخزين محلي مشفر وتتبع سوائل يعمل دون اتصال.

**Source restoration notice — 2026-11-18:** The original source archive and APK from the earlier workspace are no longer available in this environment. This is a reconstructed source project based on the code and design documented in the development conversation, version **1.0.1+2**. It is not a byte-identical recovery of the original archive or original APK. Do not interpret the earlier build's test results as verification of this restoration. Current verification is recorded in `docs/VERIFICATION.md` and the GitHub Actions run for the current commit.

## Build in GitHub

Push the complete project to `main`. **Build HydraMind Android APK** runs localization, analysis, tests and an ARM64 release build, uploads an artifact, then publishes a GitHub Release only after the build succeeds. No provider credentials or personal GitHub token are needed for the APK build. Releases use the job-scoped `GITHUB_TOKEN` with Contents write; build steps use Contents read.

For manual execution: **Actions → Build HydraMind Android APK → Run workflow**. Leave the release checkbox enabled for a public APK link; disable it for an artifact-only test build.

Download from **Releases → latest Android build → Assets → HydraMind-AI-android-arm64.apk** in Chrome. Alternatively download the Actions artifact ZIP while signed into GitHub, then unzip it on your phone. The workflow does not claim success if source is missing or any check fails.

Minimum supported device: Android 8 / API 26, ARM64. Without signing secrets, this is an evaluation APK signed with a runner development key. Keys can differ between builds, so updating a previous installation may require uninstalling it, which may erase local data. Use your own persistent upload keystore before distribution. See [cloud signing/build instructions](docs/CLOUD_BUILD.md).

## Local development

The restored project uses Flutter **3.47.9 / Dart 3.13.7**, Java **21**, Android SDK **36**, NDK **28.2.13676358**, AGP **9.1.0** and Kotlin **2.4.0**. Native toolchains are aligned across plugins. Dependencies are locked. The `image` override avoids the previously observed image/archive codec incompatibility.

```bash
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter analyze
flutter test
flutter run
flutter build apk --release --target-platform android-arm64
```

No provider key is required for public Open-Meteo city search and forecasts. Review the provider's current commercial licensing and terms before a commercial release.

## Actual features in the restored source

- Arabic first installation regardless of OS language; instant persisted Arabic/English switch; Cairo font with included SIL OFL license; RTL/LTR delegates and localized numeric entry, dates and times.
- Profile onboarding, saved steps, optional health fields, consent and later editing.
- Water, tea, coffee, milk, juice and other beverages; actual volume accounting, quick cups, notes, time editing, edit/delete/undo and persistent historical target snapshots.
- Independent population-estimate and safety engines, medical review, prescribed fluid ceilings and rapid-volume warnings. Targets do not increase automatically for weather or exercise.
- Drift SQLite with an AES-256-GCM encrypted state payload and secure-storage key; serialized atomic writes, authentication-failure recovery and local deletion.
- Real weather search, approximate location, saved cities, 30-minute cache labels, current/hourly/five-day forecasts, city time offset and daily peak UV. No invented live weather or official alerts.
- Iraq Heat Mode, five exposure profiles, cautious cooling/rest guidance and emergency information.
- Sleep-aware local inexact notifications, bounded future queue, Android quick-log/snooze actions, silent channel, adaptive suppression after logs/at goal, opened-notification history and boot restoration.
- On-device statistical habits after seven completed logged days; transparent empirical rest-of-day projections; disable/reset controls. Missing logs are not evidence of missing drinking.
- Local Arabic coach and optional server-side Gemini topic routing. Raw model text and model-generated doses are never displayed. Final local safety checks have priority.
- Daily/rolling 7/30/365-day charts and actual beverage totals, calendar volume tiles, Arabic PDF/CSV sharing and logging-consistency achievements.
- Optional read-only Health Connect/HealthKit workout durations, with overlapping intervals merged. Health SDK data is not sent to the coach and never changes fluid targets.
- Light/dark/system themes, local privacy controls, history/conversation deletion and complete local reset.

## Optional backend

The `backend` directory contains FastAPI, tests, a Dockerfile and TLS proxy example. Configure `HYDRA_CLIENT_TOKEN` and `GEMINI_API_KEY` privately on your server using `backend/.env.example`. The app's Cloud settings accept your HTTPS server URL and server token with consent. Never put a Gemini key in Flutter, source control, workflow logs or chat.

```bash
cd backend
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
cp .env.example .env
# Configure the private file locally or use a managed secret store.
.venv/bin/uvicorn app.main:app --env-file .env --host 127.0.0.1 --port 8000 --no-access-log --workers 1
.venv/bin/python -m pytest -q
```

Use HTTPS through a reverse proxy with an 8 KB streaming body limit (example included); keep Uvicorn on loopback/private networking. This single-user proxy is not a multi-user authentication platform. Its in-memory rate limit assumes one worker. It accepts the question and language preferences only, rejects extra medical/profile fields, and returns only an allowlisted topic. Provider calls require your own credentials and have not been live-tested here.

## iOS

The Xcode project, iOS 14+ Podfile, HealthKit entitlement and permission descriptions are included. On macOS run `flutter pub get`, `cd ios && pod install`, then open `Runner.xcworkspace`, configure your team/bundle ID and HealthKit capability, and archive. iOS compilation and hardware behavior are not verified by this Linux/cloud Android workflow. Android notification quick actions do not currently have iOS equivalents.

## Structure and limitations

`lib/core/domain` holds pure engines, `lib/core/database` the encrypted repository, `lib/core/services` the external/native services, `lib/features` connected screens, `lib/app` Riverpod and navigation, and `lib/l10n` the paired ARB resources. Schema version 1 creates the vault; future schema changes require tested migrations. One encrypted snapshot is appropriate for local personal history, not a multi-user warehouse.

Not implemented: accounts/cloud synchronization, direct wearable SDKs, advanced ML, unrestricted LLM prose, voice input, custom sound-file selection, official weather alerts and weather/consumption correlation models. Reports use rolling periods, not calendar-month accounting. Notification delivery, health permissions, exports, keychain/backup behavior and app performance require physical-device acceptance. This is an MVP, not a medically validated or certified production product. See [science and privacy](docs/SCIENCE_PRIVACY.md).
