import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/data/daily_challenges_catalog.dart';
import 'package:workin_fit/models/daily_challenge.dart';
import 'package:workin_fit/models/enums.dart';

void main() {
  group('DailyChallenge Firestore serialization', () {
    test('toFirestore omits id and keeps enum names', () {
      const DailyChallenge c = DailyChallenge(
        id: 'dc_x',
        title: '50 Push-ups',
        description: 'do them',
        type: DailyChallengeType.exercise,
        difficulty: DifficultyLevel.intermediate,
        target: 50,
        unit: 'reps',
        exerciseId: 'push_001',
        rewardPoints: 20,
      );
      final Map<String, dynamic> map = c.toFirestore();
      expect(map.containsKey('id'), isFalse);
      expect(map['type'], 'exercise');
      expect(map['difficulty'], 'intermediate');
      expect(map['target'], 50);
      expect(map['exerciseId'], 'push_001');
    });

    test('fromFirestore round-trips and takes id from the doc id', () {
      const DailyChallenge original = DailyChallenge(
        id: 'ignored',
        title: 'Plank',
        description: 'hold it',
        type: DailyChallengeType.freestyle,
        difficulty: DifficultyLevel.advanced,
        target: 300,
        unit: 'seconds',
        rewardPoints: 40,
      );
      final DailyChallenge restored = DailyChallenge.fromFirestore(
        original.toFirestore(),
        id: 'dc_doc_id',
      );
      expect(restored.id, 'dc_doc_id');
      expect(restored.title, 'Plank');
      expect(restored.type, DailyChallengeType.freestyle);
      expect(restored.difficulty, DifficultyLevel.advanced);
      expect(restored.target, 300);
      expect(restored.unit, 'seconds');
      expect(restored.rewardPoints, 40);
    });

    test('fromFirestore tolerates missing/unknown fields', () {
      final DailyChallenge c = DailyChallenge.fromFirestore(
        <String, dynamic>{'title': 'x', 'type': 'bogus'},
        id: 'dc1',
      );
      expect(c.type, DailyChallengeType.exercise); // default fallback
      expect(c.difficulty, DifficultyLevel.beginner);
      expect(c.target, 0);
      expect(c.rewardPoints, 10);
    });
  });

  group('pickForDate', () {
    List<DailyChallenge> pool(int n) => List<DailyChallenge>.generate(
          n,
          (int i) => DailyChallenge(
            id: 'p$i',
            title: 't$i',
            description: 'd',
            type: DailyChallengeType.exercise,
            difficulty: DifficultyLevel.beginner,
            target: 1,
            unit: 'reps',
          ),
        );

    test('returns 3 and is deterministic for a given date', () {
      final List<DailyChallenge> p = pool(10);
      final DateTime date = DateTime(2026, 7, 7);
      final List<DailyChallenge> a = DailyChallengesCatalog.pickForDate(p, date);
      final List<DailyChallenge> b = DailyChallengesCatalog.pickForDate(p, date);
      expect(a.length, 3);
      expect(a.map((DailyChallenge c) => c.id).toList(),
          b.map((DailyChallenge c) => c.id).toList());
    });

    test('returns the whole pool when it has 3 or fewer', () {
      expect(DailyChallengesCatalog.pickForDate(pool(2), DateTime(2026)).length, 2);
    });
  });
}
