import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const dir = dirname(fileURLToPath(import.meta.url));
const frPath = join(dir, '..', '..', 'lib', 'l10n', 'app_fr.arb');

/** French names for new bodyweight exercises (and legacy dictionary). */
const TRANSLATIONS = {
  'Staggered Push-up': 'Pompes décalées',
  'Arm Circles': 'Cercles de bras',
  'Prone I Raise': 'Élévation I allongé',
  'Prone Cobra': 'Cobra allongé',
  'Dead Hang': 'Suspension passive',
  'Fist Plank Hold': 'Planche sur poings',
  'Scapular Push-up': 'Pompes scapulaires',
  'Squat Pulse': 'Squat pulsé',
  'Frog Pump': 'Pont grenouille',
  'Curtsy Lunge': 'Fente courbette',
  'Bodyweight Hip Thrust': 'Hip thrust au poids du corps',
  'Seated Calf Raise': 'Mollets assis',
  'Heel Taps': 'Touches de talons',
  'Sit-up': 'Relevé de buste',
  'Standing Side Crunch': 'Crunch latéral debout',
  'Broad Jump': 'Saut en longueur',
  'Boxer Shuffle': 'Pas de boxeur',
  'Tempo Push-up': 'Pompes tempo',
  'Close-Hand Push-up': 'Pompes mains rapprochées',
  'Body Saw': 'Scie corporelle',
  'Bodyweight Good Morning': 'Good morning au poids du corps',
  'Chin-Up Negative': 'Négatif de chin-up',
  'Reverse Grip Hang Hold': 'Maintien en chin-up',
  'Renegade Row': 'Rowing renegade',
  'Sissy Squat Hold': 'Maintien sissy squat',
  'Sliding Hamstring Curl': 'Curl ischio-jambiers glissé',
  'Nordic Curl Negative': 'Négatif de curl nordique',
  'Standing Glute Kickback': 'Extension de hanche debout',
  'Lateral Lunge Pulse': 'Fente latérale pulsée',
  'Knee Pull-In': 'Ramener les genoux',
  'Cross-Body Mountain Climber': 'Grimpeur croisé',
  'Hollow Rock': 'Bascules corps creux',
  'Sprawl': 'Sprawl',
  'Typewriter Push-up': 'Pompes machine à écrire',
  'Archer Inverted Row': 'Traction inversée archer',
  'Shrimp Squat': 'Squat crevette',
  'Tuck Front Lever Hold': 'Maintien front lever groupé',
  'Power Skips': 'Sauts puissants',
};

const fr = JSON.parse(readFileSync(frPath, 'utf8'));
let updated = 0;

for (const [key, value] of Object.entries(fr)) {
  if (!key.endsWith('_name') || !key.startsWith('exercise_')) continue;
  const translated = TRANSLATIONS[value];
  if (translated && fr[key] !== translated) {
    fr[key] = translated;
    updated++;
  }
}

writeFileSync(frPath, JSON.stringify(fr, null, 2) + '\n', 'utf8');
console.log(`Updated ${updated} French exercise names in app_fr.arb`);
