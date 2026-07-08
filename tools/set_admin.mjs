// Grant (or revoke) the Workin Fit admin role for a user.
//
// This uses the Firebase Admin SDK, which bypasses Firestore security rules,
// so it is the intended way to bootstrap the very first admin (chicken-and-egg:
// only an admin can promote others through the app, but there is no admin yet).
//
// Usage:
//   1. npm install firebase-admin
//   2. Download a service-account key from the Firebase console:
//        Project settings → Service accounts → Generate new private key
//      Save it and point GOOGLE_APPLICATION_CREDENTIALS at it, e.g.:
//        export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/serviceAccount.json
//   3. Run with the target user's UID (find it in Authentication → Users):
//        node tools/set_admin.mjs <uid>            # grant admin
//        node tools/set_admin.mjs <uid> --revoke   # demote to normal user
//
// The user document (users/{uid}) must already exist (it is created on
// first sign-in). This script only sets the `role` field.

import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const uid = process.argv[2];
const revoke = process.argv.includes('--revoke');

if (!uid) {
  console.error('Usage: node tools/set_admin.mjs <uid> [--revoke]');
  process.exit(1);
}

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

const role = revoke ? 'user' : 'admin';
const ref = db.collection('users').doc(uid);

const snap = await ref.get();
if (!snap.exists) {
  console.error(
    `❌ users/${uid} does not exist. The user must sign in at least once first.`,
  );
  process.exit(1);
}

await ref.set({ role }, { merge: true });
console.log(`✅ Set role="${role}" for users/${uid}`);
process.exit(0);
