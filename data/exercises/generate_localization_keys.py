#!/usr/bin/env python3
"""
Script to:
1. Convert exercise JSON files to use localization keys instead of hardcoded text
2. Generate ARB entries for all exercises (English and French)
"""

import json
import os
from pathlib import Path

script_dir = Path(__file__).parent
l10n_dir = Path(__file__).parent.parent.parent / 'lib' / 'l10n'

# Read all exercise files
difficulty_files = ['beginner.json', 'intermediate.json', 'advanced.json']
all_exercises = []

for filename in difficulty_files:
    filepath = script_dir / filename
    if filepath.exists():
        with open(filepath, 'r') as f:
            exercises = json.load(f)
            all_exercises.extend(exercises)

print(f'Found {len(all_exercises)} exercises\n')

# Generate ARB entries
arb_en_entries = {}
arb_fr_entries = {}

# Read existing ARB files to preserve current entries
en_arb_path = l10n_dir / 'app_en.arb'
fr_arb_path = l10n_dir / 'app_fr.arb'

existing_en = {}
existing_fr = {}

if en_arb_path.exists():
    with open(en_arb_path, 'r', encoding='utf-8') as f:
        existing_en = json.load(f)
        # Remove @@locale key for processing
        existing_en.pop('@@locale', None)

if fr_arb_path.exists():
    with open(fr_arb_path, 'r', encoding='utf-8') as f:
        existing_fr = json.load(f)
        existing_fr.pop('@@locale', None)

# Generate keys for each exercise
for exercise in all_exercises:
    ex_id = exercise['id']
    
    # Name
    name_key = f'exercise_{ex_id}_name'
    arb_en_entries[name_key] = exercise['name']
    arb_fr_entries[name_key] = existing_fr.get(name_key, exercise['name'])
    
    # Description
    desc_key = f'exercise_{ex_id}_description'
    arb_en_entries[desc_key] = exercise['description']
    arb_fr_entries[desc_key] = existing_fr.get(desc_key, exercise['description'])
    
    # Beginner tips (if exists)
    if exercise.get('beginnerTips'):
        tips_key = f'exercise_{ex_id}_beginner_tips'
        arb_en_entries[tips_key] = exercise['beginnerTips']
        arb_fr_entries[tips_key] = existing_fr.get(tips_key, exercise['beginnerTips'])

# Merge with existing entries
final_en = {'@@locale': 'en', **existing_en, **arb_en_entries}
final_fr = {'@@locale': 'fr', **existing_fr, **arb_fr_entries}

# Write updated ARB files
with open(en_arb_path, 'w', encoding='utf-8') as f:
    json.dump(final_en, f, indent=2, ensure_ascii=False)
    print(f'✅ Updated {en_arb_path} with {len(arb_en_entries)} exercise entries')

with open(fr_arb_path, 'w', encoding='utf-8') as f:
    json.dump(final_fr, f, indent=2, ensure_ascii=False)
    print(f'✅ Updated {fr_arb_path} with {len(arb_fr_entries)} exercise entries (preserved existing translations)')

# Now update JSON files to use keys
print('\n📝 Updating exercise JSON files to use localization keys...')

for filename in difficulty_files:
    filepath = script_dir / filename
    if filepath.exists():
        with open(filepath, 'r') as f:
            exercises = json.load(f)
        
        # Update each exercise to use keys
        for exercise in exercises:
            ex_id = exercise['id']
            exercise['nameKey'] = f'exercise_{ex_id}_name'
            exercise['descriptionKey'] = f'exercise_{ex_id}_description'
            if exercise.get('beginnerTips'):
                exercise['beginnerTipsKey'] = f'exercise_{ex_id}_beginner_tips'
            
            # Remove old text fields (keep for now as fallback, comment out)
            # exercise.pop('name', None)
            # exercise.pop('description', None)
            # exercise.pop('beginnerTips', None)
        
        # Write updated file
        with open(filepath, 'w') as f:
            json.dump(exercises, f, indent=2)
        print(f'✅ Updated {filename}')

# Update all.json
all_file = script_dir / 'all.json'
if all_file.exists():
    with open(all_file, 'r') as f:
        all_exercises = json.load(f)
    
    for exercise in all_exercises:
        ex_id = exercise['id']
        exercise['nameKey'] = f'exercise_{ex_id}_name'
        exercise['descriptionKey'] = f'exercise_{ex_id}_description'
        if exercise.get('beginnerTips'):
            exercise['beginnerTipsKey'] = f'exercise_{ex_id}_beginner_tips'
    
    with open(all_file, 'w') as f:
        json.dump(all_exercises, f, indent=2)
    print(f'✅ Updated all.json')

print(f'\n✨ Done! Generated {len(arb_en_entries)} localization keys')
print('ℹ️  Existing French translations were preserved when present')
