class AppConstants {
  // App Info
  static const String appName = 'Workin Fit';
  static const String appVersion = '1.0.0';
  
  // Timing (from requirements)
  static const int defaultSetRestTime = 60; // 60s between sets
  static const int defaultExerciseRestTime = 120; // 120s between exercises
  static const int defaultTabataWorkTime = 20; // 20s work
  static const int defaultTabataRestTime = 10; // 10s rest
  static const int transitionTime = 5; // 5s to get ready
  
  // Warmup Durations (in seconds)
  static const int warmup2Min = 120;
  static const int warmup5Min = 300;
  static const int warmup10Min = 600;
  
  // Limits (free tier)
  static const int maxCustomSessions = 20;
  static const int maxCustomPrograms = 5;
  
  // Pagination
  static const int pageSize = 20;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 20;
  static const int minUsernameLength = 3;
  
  // Content
  static const int totalExercisesTarget = 100;
}

class FirebaseConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String exercisesCollection = 'exercises';
  static const String sessionsCollection = 'sessions';
  static const String programsCollection = 'programs';
  static const String warmupsCollection = 'warmups';
  static const String workoutHistoryCollection = 'workout_history';
  static const String dailyChallengesCollection = 'daily_challenges';
  static const String friendsCollection = 'friends';
  static const String friendRequestsCollection = 'friend_requests';
  static const String chatsCollection = 'chats';
  static const String achievementsCollection = 'achievements';
  static const String streaksCollection = 'streaks';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String exerciseImagesPath = 'exercise_images';
}