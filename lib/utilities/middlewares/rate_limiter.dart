class RateLimiter {
  final Map<String, DateTime> _lastAttempts = {};
  final Duration _defaultCooldown;
  final Map<String, Duration> _operationCooldowns;

  RateLimiter({
    required Duration defaultCooldown,  // Required parameter
    Map<String, Duration>? operationCooldowns,  // Optional parameter
  }) : _defaultCooldown = defaultCooldown,
       _operationCooldowns = operationCooldowns ?? {};

  bool isRateLimited(String operationKey) => !canProceed(operationKey);

  bool canProceed(String operationKey) {
    final lastAttempt = _lastAttempts[operationKey];
    if (lastAttempt == null) return true;
    
    final cooldown = _operationCooldowns[operationKey] ?? _defaultCooldown;
    return DateTime.now().difference(lastAttempt) > cooldown;
  }

  void recordAttempt(String operationKey) {
    _lastAttempts[operationKey] = DateTime.now();
  }

  Duration timeRemaining(String operationKey) {
    final lastAttempt = _lastAttempts[operationKey];
    if (lastAttempt == null) return Duration.zero;
    
    final cooldown = _operationCooldowns[operationKey] ?? _defaultCooldown;
    final difference = DateTime.now().difference(lastAttempt);
    return difference < cooldown ? cooldown - difference : Duration.zero;
  }
}