import 'package:flutter_test/flutter_test.dart';
import 'package:workin_fit/core/utils/content_moderation.dart';

void main() {
  group('ContentModeration', () {
    test('clean text passes', () {
      expect(ContentModeration.isClean('Push Up'), isTrue);
      expect(ContentModeration.isClean('Full body strength workout'), isTrue);
      expect(ContentModeration.validate('Barbell squat'), isNull);
    });

    test('null / empty is treated as clean', () {
      expect(ContentModeration.isClean(null), isTrue);
      expect(ContentModeration.isClean(''), isTrue);
      expect(ContentModeration.isClean('   '), isTrue);
    });

    test('detects banned words regardless of case and punctuation', () {
      expect(ContentModeration.firstBannedWord('this is SHIT'), 'shit');
      expect(ContentModeration.firstBannedWord('what the fuck!'), 'fuck');
      expect(ContentModeration.isClean('you bitch'), isFalse);
    });

    test('validate returns a helpful message with the offending word', () {
      final String? msg = ContentModeration.validate('total shit exercise');
      expect(msg, isNotNull);
      expect(msg, contains('shit'));
    });

    test('does not flag innocent words containing banned substrings', () {
      // Whole-word matching only — the Scunthorpe problem must not trigger.
      expect(ContentModeration.isClean('grape'), isTrue); // contains "rape"
      expect(ContentModeration.isClean('assess your form'), isTrue); // "ass"
      expect(ContentModeration.isClean('classic pushup'), isTrue);
    });
  });
}
