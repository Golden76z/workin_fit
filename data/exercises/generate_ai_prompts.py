#!/usr/bin/env python3
"""
Script to generate AI image prompts for all exercises in all.json.
Writes the result to both a text file (easy to read) and a JSON file (structured).
"""

import json
from pathlib import Path

# Get directory where script is located
script_dir = Path(__file__).parent
all_json_path = script_dir / 'all.json'

if not all_json_path.exists():
    print(f"Error: {all_json_path} does not exist. Please run combine_exercises.py first.")
    exit(1)

# Load exercises
with open(all_json_path, 'r', encoding='utf-8') as f:
    exercises = json.load(f)

print(f"Loaded {len(exercises)} exercises from all.json")

prompts_txt = []
prompts_json = {}

for exercise in exercises:
    ex_id = exercise.get('id', '')
    name = exercise.get('name', '')
    desc = exercise.get('description', '')
    difficulty = exercise.get('difficulty', 'beginner')
    
    # Clean the name for the prompt
    clean_name = name.lower()
    
    # Tailor the movement description based on keywords
    is_isometric = any(kw in clean_name or kw in desc.lower() for kw in ['plank', 'hold', 'sit', 'stretch', 'bridge'])
    
    if is_isometric:
        movement_details = "side profile view showing perfect hold alignment"
    else:
        movement_details = "side-by-side progression showing start position on the left and finish position on the right"
        
    prompt = (
        f"Flat 2D vector infographic illustration of an athletic mannequin silhouette performing a {clean_name}, "
        f"{movement_details}. The mannequin has a solid light-grey filled body with clean black outlines, "
        f"identical to the style of a muscle anatomy diagram. The active joints or movement trajectory are indicated "
        f"by a flat, solid purple (#5E2BFF) arrow. No glowing effects, no neon, no shadows, no gradients. "
        f"Solid flat black background (#111111). Clean and technical fitness app asset, 16:9 aspect ratio."
    )
    
    prompts_txt.append(f"ID: {ex_id}\nName: {name}\nPrompt: {prompt}\n{'-'*80}\n")
    prompts_json[ex_id] = {
        "name": name,
        "prompt": prompt
    }

# Write text prompts
txt_output = script_dir / 'ai_prompts.txt'
with open(txt_output, 'w', encoding='utf-8') as f:
    f.writelines(prompts_txt)

# Write JSON prompts
json_output = script_dir / 'ai_prompts.json'
with open(json_output, 'w', encoding='utf-8') as f:
    json.dump(prompts_json, f, indent=2, ensure_ascii=False)

print(f"Generated {len(exercises)} prompts!")
print(f"   - Text format: {txt_output}")
print(f"   - JSON format: {json_output}")
