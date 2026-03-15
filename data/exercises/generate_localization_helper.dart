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
  final sortedExercises = List<dynamic>.from(exercises)
    ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));

  final buffer = StringBuffer();
  buffer.writeln('// GENERATED FILE - DO NOT EDIT MANUALLY');
  buffer.writeln(
      '// Generated from: data/exercises/generate_localization_helper.dart',);
  buffer.writeln('');
  buffer.writeln('import \'package:workin_fit/l10n/app_localizations.dart\';');
  buffer.writeln('');
  buffer.writeln('/// Helper class to get localized exercise strings');
  buffer.writeln('class ExerciseLocalizationHelper {');
  buffer.writeln('  /// Get localized string by key');
  buffer.writeln(
      '  static String? getString(AppLocalizations localizations, String key) {',);
  buffer.writeln('    switch (key) {');

  // Generate switch cases for all exercise keys
  for (var exercise in sortedExercises) {
    final id = exercise['id'] as String;
    final nameKey = 'exercise_${id}_name';
    final descKey = 'exercise_${id}_description';
    final tipsKey = 'exercise_${id}_beginner_tips';

    buffer.writeln('      case \'$nameKey\':');
    buffer.writeln('        return localizations.exercise_${id}_name;');
    buffer.writeln('      case \'$descKey\':');
    buffer.writeln('        return localizations.exercise_${id}_description;');
    if (exercise['beginnerTips'] != null) {
      buffer.writeln('      case \'$tipsKey\':');
      buffer.writeln(
          '        return localizations.exercise_${id}_beginner_tips;',);
    }
  }

  buffer.writeln('      default:');
  buffer.writeln('        return null;');
  buffer.writeln('    }');
  buffer.writeln('  }');
  buffer.writeln('');
  buffer.writeln(
    '  static String? getName(AppLocalizations localizations, String exerciseId) {',
  );
  buffer.writeln(
    '    return getString(localizations, \'exercise_\${exerciseId}_name\');',
  );
  buffer.writeln('  }');
  buffer.writeln('');
  buffer.writeln('  static String? getDescription(');
  buffer.writeln('    AppLocalizations localizations,');
  buffer.writeln('    String exerciseId,');
  buffer.writeln('  ) {');
  buffer.writeln(
    '    return getString(localizations, \'exercise_\${exerciseId}_description\');',
  );
  buffer.writeln('  }');
  buffer.writeln('');
  buffer.writeln('  static String? getBeginnerTips(');
  buffer.writeln('    AppLocalizations localizations,');
  buffer.writeln('    String exerciseId,');
  buffer.writeln('  ) {');
  buffer.writeln(
    '    return getString(localizations, \'exercise_\${exerciseId}_beginner_tips\');',
  );
  buffer.writeln('  }');
  buffer.writeln('}');

  // Write to file
  final outputFile = File('lib/models/exercise_localization_helper.dart');
  await outputFile.writeAsString(buffer.toString());
  print('✅ Generated ${outputFile.path}');
}
