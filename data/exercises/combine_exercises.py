#!/usr/bin/env python3
"""
Script to combine all difficulty-level exercise files into a single all.json file.
Run this after adding exercises to individual difficulty files.
"""

import json
import os
from pathlib import Path

# Get the directory where this script is located
script_dir = Path(__file__).parent

# Difficulty files to combine
difficulty_files = ['beginner.json', 'intermediate.json', 'advanced.json']

all_exercises = []

for filename in difficulty_files:
    filepath = script_dir / filename
    if filepath.exists():
        with open(filepath, 'r') as f:
            exercises = json.load(f)
            all_exercises.extend(exercises)
        print(f'Loaded {len(exercises)} exercises from {filename}')
    else:
        print(f'Warning: {filename} not found, skipping...')

# Sort by ID for consistency
all_exercises.sort(key=lambda x: x['id'])

# Write combined file
output_file = script_dir / 'all.json'
with open(output_file, 'w') as f:
    json.dump(all_exercises, f, indent=2)

print(f'\n✅ Created {output_file} with {len(all_exercises)} total exercises')
