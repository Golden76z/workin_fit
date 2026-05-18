#!/usr/bin/env python3
"""
Translate exercise names from English to French in lib/l10n/app_fr.arb.

This script is intentionally conservative:
- It updates only `exercise_*_name` keys.
- It leaves descriptions and beginner tips unchanged.
- It reports any missing dictionary entries.
"""

from __future__ import annotations

import json
from pathlib import Path

# Translation dictionary for exercise names.
TRANSLATIONS = {
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
    "Staggered Push-up": "Pompes décalées",
    "Arm Circles": "Cercles de bras",
    "Prone I Raise": "Élévation I allongé",
    "Prone Cobra": "Cobra allongé",
    "Dead Hang": "Suspension passive",
    "Fist Plank Hold": "Planche sur poings",
    "Scapular Push-up": "Pompes scapulaires",
    "Squat Pulse": "Squat pulsé",
    "Frog Pump": "Pont grenouille",
    "Curtsy Lunge": "Fente courbette",
    "Bodyweight Hip Thrust": "Hip thrust au poids du corps",
    "Seated Calf Raise": "Mollets assis",
    "Heel Taps": "Touches de talons",
    "Sit-up": "Relevé de buste",
    "Standing Side Crunch": "Crunch latéral debout",
    "Broad Jump": "Saut en longueur",
    "Boxer Shuffle": "Pas de boxeur",
    "Tempo Push-up": "Pompes tempo",
    "Close-Hand Push-up": "Pompes mains rapprochées",
    "Body Saw": "Scie corporelle",
    "Bodyweight Good Morning": "Good morning au poids du corps",
    "Chin-Up Negative": "Négatif de chin-up",
    "Reverse Grip Hang Hold": "Maintien en chin-up",
    "Renegade Row": "Rowing renegade",
    "Sissy Squat Hold": "Maintien sissy squat",
    "Sliding Hamstring Curl": "Curl ischio-jambiers glissé",
    "Nordic Curl Negative": "Négatif de curl nordique",
    "Standing Glute Kickback": "Extension de hanche debout",
    "Lateral Lunge Pulse": "Fente latérale pulsée",
    "Knee Pull-In": "Ramener les genoux",
    "Cross-Body Mountain Climber": "Grimpeur croisé",
    "Hollow Rock": "Bascules corps creux",
    "Sprawl": "Sprawl",
    "Typewriter Push-up": "Pompes machine à écrire",
    "Archer Inverted Row": "Traction inversée archer",
    "Shrimp Squat": "Squat crevette",
    "Tuck Front Lever Hold": "Maintien front lever groupé",
    "Power Skips": "Sauts puissants",
}


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def save_json(path: Path, data: dict) -> None:
    with path.open("w", encoding="utf-8") as file:
        json.dump(data, file, indent=2, ensure_ascii=False)
        file.write("\n")


def main() -> None:
    en_path = Path("lib/l10n/app_en.arb")
    fr_path = Path("lib/l10n/app_fr.arb")

    en_data = load_json(en_path)
    fr_data = load_json(fr_path)

    name_keys = sorted(
        key
        for key in en_data
        if key.startswith("exercise_") and key.endswith("_name")
    )

    updated_count = 0
    missing = []

    for key in name_keys:
        en_name = en_data[key]
        fr_name = TRANSLATIONS.get(en_name)
        if fr_name is None:
            missing.append((key, en_name))
            continue
        if fr_data.get(key) != fr_name:
            fr_data[key] = fr_name
            updated_count += 1

    save_json(fr_path, fr_data)

    print(f"Exercise names found: {len(name_keys)}")
    print(f"Updated French entries: {updated_count}")
    if missing:
        print(f"Missing dictionary entries: {len(missing)}")
        for key, en_name in missing:
            print(f"- {key}: {en_name}")
    else:
        print("Missing dictionary entries: 0")
    print(f"Saved: {fr_path}")


if __name__ == "__main__":
    main()
