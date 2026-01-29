# French Translation Guide for Exercises

## Status
- ✅ 300 ARB entries created (100 exercises × 3 fields)
- ⚠️  All currently have English text - need French translation

## Translation Options

### Option 1: Use Translation API (Recommended)
Use Google Translate API or DeepL API to translate all entries:

```python
# Example using DeepL (requires API key)
import deepl

translator = deepl.Translator("YOUR_API_KEY")
result = translator.translate_text("Push-up", target_lang="FR")
```

### Option 2: Manual Translation
Translate exercise by exercise. Key terms:
- Push-up → Pompes
- Squat → Squat (same in French)
- Plank → Planche
- Lunge → Fente
- etc.

### Option 3: Use Online Translation Tool
1. Export exercise descriptions to CSV
2. Use Google Translate or DeepL web interface
3. Import back to ARB files

## Quick Translation Reference

### Exercise Names (Common)
- Push-up → Pompes
- Incline Push-up → Pompes inclinées  
- Decline Push-up → Pompes déclinées
- Diamond Push-up → Pompes diamant
- Wide Push-up → Pompes larges
- Wall Push-up → Pompes au mur
- Knee Push-up → Pompes sur les genoux
- Tricep Dips → Dips triceps
- Inverted Row → Tractions inversées
- Bodyweight Squat → Squat au poids du corps
- Forward Lunge → Fente avant
- Reverse Lunge → Fente arrière
- Glute Bridge → Pont fessier
- Plank → Planche
- Side Plank → Planche latérale
- Mountain Climbers → Grimpeurs
- Jumping Jacks → Sauts écartés
- Burpees → Burpees (same)

### Common Phrases
- "Start with..." → "Commencez par..."
- "Keep..." → "Gardez..."
- "Lower..." → "Descendez..."
- "Lift..." → "Soulevez..."
- "Hold..." → "Maintenez..."
- "Focus on..." → "Concentrez-vous sur..."

## Next Steps

1. **For now**: The app will work with English text in French ARB (fallback)
2. **Priority**: Translate exercise names first (100 entries)
3. **Then**: Translate descriptions (100 entries)  
4. **Finally**: Translate beginner tips (100 entries)

## Automated Translation Script

See `translate_exercises_fr.py` for a script that can help automate translations using translation APIs.
