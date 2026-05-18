import { readFileSync, mkdirSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const allJson = join(root, 'data', 'exercises', 'all.json');
const movementsRoot = join(root, 'assets', 'exercises', 'movements');

const exercises = JSON.parse(readFileSync(allJson, 'utf8'));
mkdirSync(movementsRoot, { recursive: true });

const readme = `# Place tutorial.gif in this folder (1080×608 recommended).
# App path: assets/exercises/movements/{id}/tutorial.gif
`;

let count = 0;
for (const { id } of exercises) {
  const dir = join(movementsRoot, id);
  mkdirSync(dir, { recursive: true });
  const gitkeep = join(dir, '.gitkeep');
  writeFileSync(gitkeep, '', 'utf8');
  count++;
}

console.log(`Created ${count} folders under assets/exercises/movements/`);
