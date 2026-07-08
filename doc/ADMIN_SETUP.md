# Admin Content Management — Setup

This app has an in-app admin interface for authoring shared content (exercises,
programs, and — behind stubs — warmups & daily challenges). Admin access is
controlled by a `role` field on each user's Firestore document and enforced by
security rules.

## How admin access works

- Each `users/{uid}` document may have a `role` field: `"admin"` or `"user"`
  (absent/default = `"user"`).
- The app watches the signed-in user's profile via `currentUserProfileProvider`
  and exposes `isAdminProvider`. When `true`:
  - An **Admin** entry appears in Profile → Account.
  - Admin screens (`lib/views/admin/`) render; otherwise `AdminGuard` shows an
    "access required" screen.
- Writes to content collections and exercise images are additionally rejected
  server-side by `firestore.rules` / `storage.rules` unless the caller is an
  admin. The UI gate is convenience; the rules are the real boundary.
- Users **cannot** promote themselves: the rules forbid a user changing their
  own `role`. Only an existing admin (via the app) or the Admin SDK / Firebase
  Console (which bypass rules) can grant admin.

## 1. Deploy the security rules

The rules live at `firestore.rules` and `storage.rules`. Deploy them with the
Firebase CLI (from the project root). If `firebase.json` doesn't reference them
yet, add:

```json
{
  "firestore": { "rules": "firestore.rules" },
  "storage":   { "rules": "storage.rules" }
}
```

Then:

```bash
firebase deploy --only firestore:rules,storage
```

You can also paste the rule contents directly in the Firebase Console
(Firestore → Rules, Storage → Rules).

## 2. Bootstrap the first admin

Because only an admin can promote others in-app, grant the first admin out of
band. Two options:

### Option A — Firebase Console (quickest)

1. Have the target user sign in once (creates their `users/{uid}` doc).
2. Console → Firestore → `users` → open their document.
3. Add a field `role` (string) = `admin`. Save.

### Option B — Admin SDK script (repeatable)

```bash
npm install firebase-admin
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json
node tools/set_admin.mjs <uid>            # grant admin
node tools/set_admin.mjs <uid> --revoke   # demote
```

Find the UID in Console → Authentication → Users. See `tools/set_admin.mjs`
for details.

After the role is set, the user sees the Admin entry the next time their profile
document syncs (it's a live stream, so usually immediately).

## 3. Using the admin tools

Profile → **Admin** opens the dashboard:

- **Exercises** — full create / edit / delete. Pick muscle-diagram and tutorial
  images from the gallery (uploaded to `exercise_images/` in Storage), choose
  difficulty and muscle groups, list equipment. All free-text is screened by
  `ContentModeration` (banned-words filter) before saving. Saved exercises
  appear immediately for all users via the live `exercisesStream`.
- **Programs** — minimal create form writing to the preset `programs` collection.
- **Daily Challenges** — full list + editor writing to the `daily_challenges`
  collection. Authored challenges take over the home-screen daily rotation for
  everyone; when none exist the app falls back to the built-in catalog
  (`todaysChallengesProvider` prefers Firestore, falls back to
  `DailyChallengesCatalog`).
- **Warmups** — list + editor for authoring routines keyed by
  (category, duration). Saving overrides the built-in `WarmupData` routine for
  that key for everyone; deleting restores the built-in one
  (`warmupRoutineProvider` prefers Firestore, falls back to `WarmupData`).

## Notes / follow-ups

- Content moderation is client-side and best-effort — extend the word list in
  `lib/core/utils/content_moderation.dart`. For stronger guarantees, mirror it
  in a Cloud Function on write.
- If you later want tamper-proof roles independent of Firestore reads, you can
  layer Firebase Auth **custom claims** on top (set them from an Admin-SDK
  Cloud Function that watches the `role` field), then check the claim in rules
  via `request.auth.token.admin`.
