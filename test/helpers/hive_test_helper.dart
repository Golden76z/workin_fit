import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workin_fit/models/enums.dart';
import 'package:workin_fit/models/exercise.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/session.dart';
import 'package:workin_fit/models/workout_config.dart';

/// Initializes Hive with a temp directory and registers all adapters.
/// Call in [setUp]. Pair with [tearDownHive] in [tearDown].
Future<Directory> setUpHive() async {
  final dir = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(dir.path);
  _registerAdapters();
  return dir;
}

/// Closes all Hive boxes and deletes the temp directory.
Future<void> tearDownHive(Directory dir) async {
  await Hive.close();
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ExerciseAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SessionAdapter());
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(WorkoutConfigAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SetsConfigAdapter());
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(TabataConfigAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(TimedConfigAdapter());
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(CircuitConfigAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(ProgramAdapter());
  if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(WorkoutTypeAdapter());
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(DifficultyLevelAdapter());
  }
  if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(MuscleGroupAdapter());
}
