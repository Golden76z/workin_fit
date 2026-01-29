#!/usr/bin/env python3
"""
Script to translate exercise entries from English to French in app_fr.arb
This script reads the English ARB file and creates French translations.
"""

import json
import re

# Translation dictionary for common exercise terms
TRANSLATIONS = {
    # Exercise names
    "Push-up": "Pompes",
    "Incline Push-up": "Pompes inclinées",
    "Decline Push-up": "Pompes déclinées",
    "Diamond Push-up": "Pompes diamant",
    "Wide Push-up": "Pompes larges",
    "Pike Push-up": "Pompes pike",
    "Wall Push-up": "Pompes au mur",
    "Knee Push-up": "Pompes sur les genoux",
    "Archer Push-up": "Pompes archer",
    "Hindu Push-up": "Pompes hindoues",
    "Spiderman Push-up": "Pompes Spiderman",
    "Shoulder Tap Push-up": "Pompes avec tapotement d'épaule",
    "Tricep Dips": "Dips triceps",
    "Diamond Tricep Dips": "Dips triceps diamant",
    "Wall Sit": "Chaise au mur",
    "Pseudo Planche Push-up": "Pompes pseudo planche",
    "Clapping Push-up": "Pompes avec claquement",
    "One-Arm Push-up": "Pompes à un bras",
    "Handstand Push-up": "Pompes en équilibre sur les mains",
    "Dive Bomber Push-up": "Pompes plongeant",
    
    "Inverted Row": "Tractions inversées",
    "Superman": "Superman",
    "Reverse Snow Angels": "Anges de neige inversés",
    "Y-T-W Raises": "Élévations Y-T-W",
    "Wall Angels": "Anges au mur",
    "Prone Y Raise": "Élévation Y allongé",
    "Prone T Raise": "Élévation T allongé",
    "Prone W Raise": "Élévation W allongé",
    "Scapular Wall Slides": "Glissades scapulaires au mur",
    "Reverse Plank": "Planche inversée",
    "Isometric Pull Hold": "Maintien isométrique de traction",
    "Reverse Plank Walk": "Marche en planche inversée",
    "Single Arm Row": "Rowing à un bras",
    "Towel Row": "Rowing avec serviette",
    "Doorway Row": "Rowing dans l'encadrement",
    "Australian Pull-up": "Tractions australiennes",
    "Pull-up Negative": "Négatif de traction",
    "Wide Grip Inverted Row": "Tractions inversées prise large",
    "Close Grip Inverted Row": "Tractions inversées prise serrée",
    "Reverse Fly": "Écarté inversé",
    
    "Bodyweight Squat": "Squat au poids du corps",
    "Jump Squat": "Squat sauté",
    "Pistol Squat": "Pistol squat",
    "Bulgarian Split Squat": "Squat bulgare",
    "Forward Lunge": "Fente avant",
    "Reverse Lunge": "Fente arrière",
    "Walking Lunge": "Fente marchée",
    "Jumping Lunge": "Fente sautée",
    "Side Lunge": "Fente latérale",
    "Calf Raise": "Relevé de mollets",
    "Single Leg Calf Raise": "Relevé de mollets à une jambe",
    "Glute Bridge": "Pont fessier",
    "Single Leg Glute Bridge": "Pont fessier à une jambe",
    "Donkey Kicks": "Coups de pied d'âne",
    "Fire Hydrants": "Borne d'incendie",
    "Clamshells": "Coquillages",
    "Leg Raises": "Relevés de jambes",
    "Single Leg Deadlift": "Soulevé de terre à une jambe",
    "Skater Squats": "Squats patineur",
    "Step-up": "Montée sur banc",
    "Sumo Squat": "Squat sumo",
    "Single Leg Squat": "Squat à une jambe",
    "Cossack Squat": "Squat cosaque",
    "Wall Sit Pulse": "Pulsation chaise au mur",
    "Jump Squat to Tuck": "Squat sauté avec genoux au buste",
    
    "Plank": "Planche",
    "Side Plank": "Planche latérale",
    "Mountain Climbers": "Grimpeurs",
    "Bicycle Crunches": "Crunchs vélo",
    "Russian Twists": "Twists russes",
    "Flutter Kicks": "Battements de jambes",
    "Dead Bug": "Insecte mort",
    "Bird Dog": "Chien oiseau",
    "Hollow Body Hold": "Maintien corps creux",
    "V-Ups": "V-ups",
    "Toe Touches": "Touches d'orteils",
    "Reverse Crunches": "Crunchs inversés",
    "Plank Jacks": "Planche sautée",
    "Bear Crawl": "Marche de l'ours",
    "Crab Walk": "Marche du crabe",
    "Windshield Wipers": "Essuie-glaces",
    "L-Sit": "Assise en L",
    "Plank to Downward Dog": "Planche vers chien tête en bas",
    "Side Plank with Leg Lift": "Planche latérale avec levée de jambe",
    "Plank Up-Downs": "Planche haut-bas",
    
    "Jumping Jacks": "Sauts écartés",
    "High Knees": "Genoux hauts",
    "Butt Kicks": "Talons-fesses",
    "Burpees": "Burpees",
    "Skater Jumps": "Sauts patineur",
    "Star Jumps": "Sauts en étoile",
    "Tuck Jumps": "Sauts groupés",
    "Inchworms": "Chenilles",
    "Shadow Boxing": "Boxe de l'ombre",
    "Jump Rope (No Rope)": "Saut à la corde (sans corde)",
    "Fast Feet": "Pieds rapides",
    "Squat Jumps": "Sauts de squat",
    "Lunge Jumps": "Sauts de fente",
    "Dancing in Place": "Danse sur place",
    "Jumping Lunges": "Fentes sautées",
}

def translate_text(text):
    """Simple translation - in production, use a proper translation API"""
    # This is a placeholder - you'd use Google Translate API or similar
    # For now, return the text with a note that it needs translation
    return text

# Read English ARB
with open('lib/l10n/app_en.arb', 'r', encoding='utf-8') as f:
    en_data = json.load(f)

# Read French ARB
with open('lib/l10n/app_fr.arb', 'r', encoding='utf-8') as f:
    fr_data = json.load(f)

# Find all exercise entries
exercise_keys = [k for k in en_data.keys() if k.startswith('exercise_')]

print(f"Found {len(exercise_keys)} exercise keys to translate")
print("Note: This script provides a framework. Manual translation or API integration needed.")
print("\nTo complete translations, you can:")
print("1. Use Google Translate API")
print("2. Use DeepL API")
print("3. Manual translation")
print("\nFor now, the French file has English placeholders that need translation.")
