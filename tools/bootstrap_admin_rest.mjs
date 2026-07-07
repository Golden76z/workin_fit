// Bootstrap the first admin WITHOUT a service account, using the Firebase REST
// API. Works only for accounts that have an email+password sign-in method and
// only if the live Firestore rules let a user write their own `users/{uid}`
// document (typical). Otherwise use the Firebase Console or a service account.
//
// The password is read from an environment variable so it never has to be
// pasted into a shared session:
//
//   ADMIN_EMAIL='goldenscrooz@gmail.com' \
//   ADMIN_PASSWORD='<the-password>' \
//   node tools/bootstrap_admin_rest.mjs
//
// Optional: ADMIN_ROLE=user to demote instead of promote.

import { readFileSync } from 'node:fs';

const email = process.env.ADMIN_EMAIL;
const password = process.env.ADMIN_PASSWORD;
const role = process.env.ADMIN_ROLE || 'admin';

if (!email || !password) {
  console.error(
    "Set ADMIN_EMAIL and ADMIN_PASSWORD env vars. Example:\n" +
      "  ADMIN_EMAIL='you@example.com' ADMIN_PASSWORD='secret' node tools/bootstrap_admin_rest.mjs",
  );
  process.exit(1);
}

const gs = JSON.parse(readFileSync('android/app/google-services.json', 'utf8'));
const projectId = gs.project_info.project_id;
const apiKey = gs.client[0].api_key[0].current_key;

// 1. Sign in to obtain an ID token + uid.
const signInRes = await fetch(
  `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
  {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, returnSecureToken: true }),
  },
);
const signIn = await signInRes.json();
if (!signInRes.ok) {
  console.error('❌ Sign-in failed:', signIn.error?.message || signInRes.status);
  console.error(
    '   (If this says the account uses a different provider, e.g. Google, use the Firebase Console instead.)',
  );
  process.exit(1);
}
const { idToken, localId: uid } = signIn;
console.log(`Signed in as ${email} (uid ${uid})`);

// 2. Patch users/{uid}.role via Firestore REST (merge just the role field).
const patchRes = await fetch(
  `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${uid}?updateMask.fieldPaths=role`,
  {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${idToken}`,
    },
    body: JSON.stringify({ fields: { role: { stringValue: role } } }),
  },
);
const patch = await patchRes.json();
if (!patchRes.ok) {
  console.error('❌ Failed to set role:', patch.error?.message || patchRes.status);
  console.error(
    '   The live security rules may forbid users changing their own role. Use the Firebase Console or a service account.',
  );
  process.exit(1);
}

console.log(`✅ Set role="${role}" on users/${uid}. Restart/refresh the app to see admin tools.`);
