/// Simple client-side content moderation for user- and admin-generated text.
///
/// This is a lightweight, best-effort profanity/abuse filter intended to catch
/// obvious violations in content authored inside the app (exercise names,
/// descriptions, tips, program/warmup titles, etc.). It is deliberately
/// conservative: it matches whole words (case-insensitive, ignoring common
/// separators) to avoid the "Scunthorpe problem" of flagging innocent
/// substrings.
///
/// It is NOT a security boundary — server-side Firestore rules gate *who* can
/// write. This gates *what* gets written by well-behaved clients.
class ContentModeration {
  const ContentModeration._();

  /// Base set of disallowed words. Kept intentionally small and obvious; extend
  /// as needed. Stored lowercase, without separators.
  static const Set<String> _bannedWords = <String>{
    'fuck',
    'shit',
    'bitch',
    'cunt',
    'asshole',
    'bastard',
    'dick',
    'piss',
    'nigger',
    'nigga',
    'faggot',
    'retard',
    'slut',
    'whore',
    'rape',
  };

  /// Returns the first banned word found in [text], or `null` if the text is
  /// clean.
  ///
  /// Matching is whole-word (case-insensitive): the input is lower-cased and
  /// split on any run of non-alphanumeric characters, then each token is
  /// checked against the banned set. This deliberately avoids substring
  /// matching so innocent words are never flagged (the "Scunthorpe problem" —
  /// e.g. `grape` must not trip on `rape`, `assess` must not trip on `ass`).
  static String? firstBannedWord(String? text) {
    if (text == null || text.trim().isEmpty) return null;

    final Iterable<String> tokens = text
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((String t) => t.isNotEmpty);

    for (final String token in tokens) {
      if (_bannedWords.contains(token)) return token;
    }
    return null;
  }

  /// Whether [text] contains any banned word.
  static bool isClean(String? text) => firstBannedWord(text) == null;

  /// A form-validator-friendly check. Returns an error message when [text]
  /// contains banned content, or `null` when it's acceptable. Empty/null input
  /// is treated as clean (use a separate required-field validator for that).
  static String? validate(String? text) {
    final String? bad = firstBannedWord(text);
    if (bad == null) return null;
    return 'Contains inappropriate language ("$bad"). Please revise.';
  }
}
