# Science, safety and privacy boundaries

The app records entered beverage volumes. It is not a measurement of body water, dehydration, sodium or medical status. Missing entries are not evidence that a person did not drink.

## Estimate assumptions

EFSA (2010), *Scientific Opinion on Dietary Reference Values for water*, https://www.efsa.europa.eu/en/efsajournal/pub/1459 , gives adult population references of 2.0 L (women) and 2.5 L (men) for **total water**, including food. The app assumes a variable, illustrative 20% food share, yielding 1,600 or 2,000 ml from beverages. When a reference is not selected, 1,800 ml is explicitly the assumed midpoint, not a new clinical reference. These are not individual prescriptions.

Children under 18, pregnancy, breastfeeding, a declared fluid-related condition, medications or medical notes suspend automatic estimates. A clinician-entered ceiling always wins, and is not a target to reach. The care plan may cover fluid sources this beverage tracker does not capture. No automatic per-degree, weight, exercise or sweating multiplier is applied.

Flags at 1,000 ml/hour or 4,000 ml/day are conservative **app review triggers**, not clinically safe maxima, diagnoses or reassurance below those values. Follow individual clinical instructions. Severe symptoms may need urgent care regardless of app numbers. The symptom lexicon is incomplete and must never delay care. Water alone does not treat heatstroke.

Heat levels use apparent temperature 27/32/40°C and dry temperature 35/40°C as informational UI triggers, not occupational WBGT or official alerts. Stale weather is not treated as live. Guidance emphasizes cooling, shade, rest and reduced exertion. See educational context at https://www.cdc.gov/niosh/heat-stress/ .

Habit projections use at least seven completed logged days in a 28-day window, adding historical remaining-clock-time amounts to today's log. The percentage is an empirical comparison, not a calibrated probability or clinical prediction. Selection bias and unlogged days matter. No causal weather claim is made.

## Data boundaries

Drift stores an AES-256-GCM encrypted state snapshot; a random key resides in Android secure storage/Apple Keychain. Nonces are fresh per write. Failed authentication does not silently erase the file. SQLite schema/approximate size and process memory are outside the content-encryption boundary. Losing the secure key can make data unrecoverable.

No accounts, cloud sync, ads, analytics SDKs or background location collection are enabled. Weather receives a city or coordinates rounded to 0.1 degrees. Cloud coach setup is optional and consented; only submitted question/language/dialect are sent. Do not include sensitive health information in cloud questions. Provider retention follows the deployment owner's Google terms; local deletion cannot erase provider copies.

Notification bodies do not contain names, conditions or recorded volumes. Lock screens can still reveal hydration-app use. Delivery while locked/closed, manufacturer battery rules, force-stop behavior and renewal after the bounded 48-slot horizon need device testing. Exact timing is not promised.

Health access is read-only and optional for workouts. Imported durations stay in screen memory, never go to the coach and do not alter targets. Revoke access in OS health permissions.

Exports are plaintext, user initiated and shared with the OS share sheet. CSV formula prefixes are guarded. Temporary app copies are deleted after sharing returns; OS/recipient/export copies remain outside local deletion. Delete-all cancels notifications, clears/vacuums the encrypted snapshot and removes backend settings, then returns to Arabic onboarding. The vault key is retained for the empty database; no profile or history remains. Flash storage and backups prevent promises of forensic erasure.

An independent security review, clinician review where appropriate, OS hardware tests, provider licensing checks, store privacy/health declarations and the owner's legal contact/disclosures remain release tasks. No compliance certification or contact identity has been fabricated.
