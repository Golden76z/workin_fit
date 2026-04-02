import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/models/program.dart';
import 'package:workin_fit/models/enums.dart';

Program _makeProgram({
  List<String>? sessionIds,
  int durationWeeks = 4,
  int daysPerWeek = 3,
}) {
  return Program(
    id: 'prog_1',
    name: 'Test Program',
    description: 'A test program',
    sessionIds: sessionIds ?? ['s1', 's2', 's3'],
    durationWeeks: durationWeeks,
    difficulty: DifficultyLevel.intermediate,
    goals: ['Strength', 'Endurance'],
    daysPerWeek: daysPerWeek,
  );
}

void main() {
  group('Program.totalSessions', () {
    test('returns count of session IDs', () {
      expect(_makeProgram(sessionIds: ['s1', 's2', 's3']).totalSessions, 3);
    });

    test('returns 0 for empty session list', () {
      expect(_makeProgram(sessionIds: []).totalSessions, 0);
    });
  });

  group('Program.totalDays', () {
    test('returns durationWeeks * 7', () {
      expect(_makeProgram(durationWeeks: 4).totalDays, 28);
    });

    test('single week is 7 days', () {
      expect(_makeProgram(durationWeeks: 1).totalDays, 7);
    });
  });

  group('Program Firestore serialization', () {
    test('toFirestore / fromFirestore roundtrip', () {
      final original = _makeProgram();

      final data = original.toFirestore();
      final restored = Program.fromFirestore(data);

      expect(restored.id, 'prog_1');
      expect(restored.name, 'Test Program');
      expect(restored.sessionIds, ['s1', 's2', 's3']);
      expect(restored.durationWeeks, 4);
      expect(restored.difficulty, DifficultyLevel.intermediate);
      expect(restored.goals, ['Strength', 'Endurance']);
      expect(restored.daysPerWeek, 3);
    });

    test('toFirestore includes all required fields', () {
      final program = _makeProgram();
      final data = program.toFirestore();

      expect(data.containsKey('id'), isTrue);
      expect(data.containsKey('name'), isTrue);
      expect(data.containsKey('sessionIds'), isTrue);
      expect(data.containsKey('durationWeeks'), isTrue);
      expect(data.containsKey('difficulty'), isTrue);
      expect(data.containsKey('goals'), isTrue);
      expect(data.containsKey('daysPerWeek'), isTrue);
      expect(data.containsKey('createdAt'), isTrue);
    });

    test('difficulty is stored as string name', () {
      final data = _makeProgram().toFirestore();
      expect(data['difficulty'], 'intermediate');
    });

    test('fromFirestore handles null createdAt', () {
      final data = {
        'id': 'p1',
        'name': 'Test',
        'description': 'desc',
        'sessionIds': <dynamic>[],
        'durationWeeks': 4,
        'difficulty': 'beginner',
        'goals': <dynamic>[],
        'daysPerWeek': 3,
        'createdAt': null,
      };
      final program = Program.fromFirestore(data);
      expect(program.id, 'p1');
    });

    test('optional imageUrl can be null', () {
      final program = _makeProgram();
      expect(program.imageUrl, isNull);
      final data = program.toFirestore();
      final restored = Program.fromFirestore(data);
      expect(restored.imageUrl, isNull);
    });
  });
}
