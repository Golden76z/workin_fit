// This script generates a helper class for exercise localization
// Run with: dart run data/exercises/generate_localization_helper.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  final exercisesFile = File('data/exercises/all.json');
  if (!await exercisesFile.exists()) {
    print('Error: data/exercises/all.json not found');
    exit(1);
  }

  final content = await exercisesFile.readAsString();
  final exercises = json.decode(content) as List<dynamic>;

  final buffer = StringBuffer();
  buffer.writeln('// GENERATED FILE - DO NOT EDIT MANUALLY');
  buffer.writeln('// Generated from: data/exercises/generate_localization_helper.dart');
  buffer.writeln('');
  buffer.writeln('import \'package:workin_fit/l10n/app_localizations.dart\';');
  buffer.writeln('');
  buffer.writeln('/// Helper class to get localized exercise strings');
  buffer.writeln('class ExerciseLocalizationHelper {');
  buffer.writeln('  /// Get localized string by key');
  buffer.writeln('  static String? getString(AppLocalizations localizations, String key) {');
  buffer.writeln('    switch (key) {');

  // Generate switch cases for all exercise keys
  for (var exercise in exercises) {
    final id = exercise['id'] as String;
    final nameKey = 'exercise_${id}_name';
    final descKey = 'exercise_${id}_description';
    final tipsKey = 'exercise_${id}_beginner_tips';

    buffer.writeln('      case \'$nameKey\':');
    buffer.writeln('        return localizations.exercise_${id.replaceAll('_', '')}_name;');
    buffer.writeln('      case \'$descKey\':');
    buffer.writeln('        return localizations.exercise_${id.replaceAll('_', '')}_description;');
    if (exercise['beginnerTips'] != null) {
      buffer.writeln('      case \'$tipsKey\':');
      buffer.writeln('        return localizations.exercise_${id.replaceAll('_', '')}_beginner_tips;');
    }
  }

  buffer.writeln('      default:');
  buffer.writeln('        return null;');
  buffer.writeln('    }');
  buffer.writeln('  }');
  buffer.writeln('}');

  // Write to file
  final outputFile = File('lib/models/exercise_localization_helper.dart');
  await outputFile.writeAsString(buffer.toString());
  print('✅ Generated ${outputFile.path}');
  print('⚠️  Note: This file uses generated getter names that may need adjustment');
  print('   Run: flutter pub run build_runner build to regenerate ARB getters');
}
