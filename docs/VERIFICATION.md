# Restored source verification — 2026-11-18

This report applies to the reconstructed 1.0.1+2 source, not to the earlier 1.0.0 APK or its lost source archive. Reconstruction was necessary because the earlier workspace files were unavailable. No old binary or source hash match is claimed.

## Checks actually run locally

- Flutter 3.47.9 / Dart 3.13.7: `flutter analyze --no-pub` — no issues.
- `flutter test --reporter expanded` — 37 tests passed.
- FastAPI `python -m pytest -q tests` — 8 tests passed. An upstream Starlette/AnyIO deprecation warning remains.
- YAML structure, shell syntax and the embedded signing Python in the GitHub Actions workflow were checked.
- Android/iOS XML and plist syntax were checked. Secrets, caches, keystores and local configuration files are excluded from upload.

The tests cover Arabic-first RTL on an English OS, persisted language switching/LTR, large text/reduced motion, Arabic onboarding checkpoints/consent, connected navigation, volume persistence, encrypted reopen and wrong-key behavior, serialized/idempotent writes, population assumptions, clinical ceilings and review profiles, rapid/daily safety flags, AI topic validation, waking hours/night shifts, DST/zone scheduling, adaptive reminders, insufficient history and empirical projections, missing/stale/failed weather, provider-field parsing, Arabic numerals, CSV injection escaping, Arabic PDF embedding, and mocked Android notification permission/payload/cancel behavior.

Backend tests cover authorization, urgent-topic routing without a provider call, disallowed model output, provider failure, rejecting extra sensitive fields/long prompts, missing credentials and rate limiting.

## Cloud acceptance

The current commit's GitHub Actions run is the authoritative source for Android compilation. This restoration does not reuse the old APK and does not claim a successful new APK until the current workflow completes. The workflow builds ARM64, uploads APK/checksum artifacts and publishes a Release after success on main. Build jobs use read-only repository access; the release job receives Contents write. No personal GitHub token, API provider key or signing secret is committed.

## Still requires configuration or physical hardware

- Native install/cold launch, locked-screen/closed-app notification delivery, reboot, manufacturer battery rules and force-stop behavior.
- GPS permission denial/revocation and location accuracy on actual Android/iOS hardware.
- Health Connect/HealthKit authorization and exercise-source compatibility.
- Native share sheets/export cleanup, secure storage/backup and accessibility audits.
- Optional live Gemini API calls: deploy the included HTTPS proxy and supply server-side credentials.
- iOS compilation/signing: macOS/Xcode required.
- Production upload signing and store privacy/health disclosures.

No automated test proves clinical accuracy. Official weather alerts, account sync, voice input, advanced ML and unrestricted LLM answers are not implemented. See README and SCIENCE_PRIVACY.md for exact scope and assumptions.
