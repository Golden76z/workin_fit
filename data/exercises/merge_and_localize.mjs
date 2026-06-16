import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const dir = dirname(fileURLToPath(import.meta.url));
const l10nDir = join(dir, '..', '..', 'lib', 'l10n');

function loadJson(path) {
  return JSON.parse(readFileSync(path, 'utf8'));
}

function saveJson(path, data) {
  writeFileSync(path, JSON.stringify(data, null, 2) + '\n', 'utf8');
}

// --- Merge additions ---
const additions = loadJson(join(dir, 'bodyweight_additions.json'));
const levels = ['beginner', 'intermediate', 'advanced'];
let totalAdded = 0;

for (const level of levels) {
  const targetPath = join(dir, `${level}.json`);
  const existing = loadJson(targetPath);
  const existingIds = new Set(existing.map((ex) => ex.id));
  const toAdd = [];

  for (const ex of additions[level] ?? []) {
    if (existingIds.has(ex.id)) continue;
    const copy = { ...ex };
    copy.nameKey = `exercise_${copy.id}_name`;
    copy.descriptionKey = `exercise_${copy.id}_description`;
    if (copy.beginnerTips) {
      copy.beginnerTipsKey = `exercise_${copy.id}_beginner_tips`;
    }
    toAdd.push(copy);
  }

  if (toAdd.length === 0) continue;

  const restIndex = existing.findIndex((ex) => ex.id.startsWith('rest_'));
  const insertAt = restIndex === -1 ? existing.length : restIndex;
  const updated = [...existing.slice(0, insertAt), ...toAdd, ...existing.slice(insertAt)];
  saveJson(targetPath, updated);
  totalAdded += toAdd.length;
  console.log(`${level}: +${toAdd.length}`);
}

// --- Combine all.json ---
const all = [];
for (const level of levels) {
  all.push(...loadJson(join(dir, `${level}.json`)));
}
all.sort((a, b) => a.id.localeCompare(b.id));
saveJson(join(dir, 'all.json'), all);
console.log(`all.json: ${all.length} exercises`);

// --- ARB generation ---
const enPath = join(l10nDir, 'app_en.arb');
const frPath = join(l10nDir, 'app_fr.arb');
const existingEn = loadJson(enPath);
const existingFr = loadJson(frPath);

for (const ex of all) {
  const nameKey = `exercise_${ex.id}_name`;
  const descKey = `exercise_${ex.id}_description`;
  existingEn[nameKey] = ex.name;
  existingEn[descKey] = ex.description;
  if (!existingFr[nameKey]) existingFr[nameKey] = ex.name;
  if (!existingFr[descKey]) existingFr[descKey] = ex.description;
  if (ex.beginnerTips) {
    const tipsKey = `exercise_${ex.id}_beginner_tips`;
    existingEn[tipsKey] = ex.beginnerTips;
    if (!existingFr[tipsKey]) existingFr[tipsKey] = ex.beginnerTips;
  }
}

saveJson(enPath, existingEn);
saveJson(frPath, existingFr);
console.log(`ARB updated (${totalAdded} new exercises merged)`);
