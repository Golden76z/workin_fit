import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/data/daily_challenges_catalog.dart';
import 'package:workin_fit/models/daily_challenge.dart';

void main() {
  group('DailyChallengesCatalog', () {
    group('all', () {
      test('returns 30 challenges', () {
        expect(DailyChallengesCatalog.all.length, 30);
      });

      test('all challenges have unique ids', () {
        final ids = DailyChallengesCatalog.all.map((c) => c.id).toSet();
        expect(ids.length, 30);
      });

      test('all challenges have non-empty titles', () {
        for (final c in DailyChallengesCatalog.all) {
          expect(c.title.isNotEmpty, isTrue, reason: '${c.id} has empty title');
        }
      });

      test('all challenges have positive targets', () {
        for (final c in DailyChallengesCatalog.all) {
          expect(c.target > 0, isTrue, reason: '${c.id} has non-positive target');
        }
      });

      test('all challenges have positive rewardPoints', () {
        for (final c in DailyChallengesCatalog.all) {
          expect(
            c.rewardPoints > 0,
            isTrue,
            reason: '${c.id} has non-positive rewardPoints',
          );
        }
      });
    });

    group('forDate', () {
      test('returns exactly 3 challenges', () {
        final result = DailyChallengesCatalog.forDate(DateTime(2024, 1, 1));
        expect(result.length, 3);
      });

      test('returns DailyChallenge instances', () {
        final result = DailyChallengesCatalog.forDate(DateTime(2024, 6, 15));
        for (final c in result) {
          expect(c, isA<DailyChallenge>());
        }
      });

      test('same date always returns same challenges', () {
        final date = DateTime(2024, 3, 10);
        final a = DailyChallengesCatalog.forDate(date);
        final b = DailyChallengesCatalog.forDate(date);
        expect(a.map((c) => c.id).toList(), b.map((c) => c.id).toList());
      });

      test('different dates return different challenges', () {
        final day1 = DailyChallengesCatalog.forDate(DateTime(2024, 1, 1));
        final day2 = DailyChallengesCatalog.forDate(DateTime(2024, 1, 2));
        // With offset of 3 per day and 30 challenges, day1 ids ≠ day2 ids
        expect(
          day1.map((c) => c.id).toList(),
          isNot(equals(day2.map((c) => c.id).toList())),
        );
      });

      test('no duplicate challenges within a single day result', () {
        final result = DailyChallengesCatalog.forDate(DateTime(2024, 5, 20));
        final ids = result.map((c) => c.id).toSet();
        expect(ids.length, result.length);
      });

      test('cycles correctly across a full year without index errors', () {
        final base = DateTime(2024, 1, 1);
        for (int i = 0; i < 365; i++) {
          final date = base.add(Duration(days: i));
          final result = DailyChallengesCatalog.forDate(date);
          expect(result.length, 3, reason: 'Failed on day $i');
        }
      });

      test('Jan 1 offset starts at 0 (first 3 challenges)', () {
        // Day 0 of year → offset = 0*3 % 30 = 0
        final result = DailyChallengesCatalog.forDate(DateTime(2024, 1, 1));
        expect(result[0].id, 'dc_001');
        expect(result[1].id, 'dc_002');
        expect(result[2].id, 'dc_003');
      });

      test('day 10 wraps correctly', () {
        // Day 10 → offset = 10*3 % 30 = 0 → same as day 0
        final day0 = DailyChallengesCatalog.forDate(DateTime(2024, 1, 1));
        final day10 = DailyChallengesCatalog.forDate(DateTime(2024, 1, 11));
        expect(
          day10.map((c) => c.id).toList(),
          day0.map((c) => c.id).toList(),
        );
      });
    });
  });
}
