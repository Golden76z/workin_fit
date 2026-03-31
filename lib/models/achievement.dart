import 'package:cloud_firestore/cloud_firestore.dart';

enum AchievementRank { bronze, silver, gold }

enum AchievementCategory {
  totalWorkouts,
  streakMilestone,
  exerciseMastery,
  programsCompleted,
}

class AchievementDefinition {
  final String id;
  final AchievementCategory category;
  final AchievementRank rank;
  final String title;
  final String description;
  final int targetValue;
  final String icon;

  const AchievementDefinition({
    required this.id,
    required this.category,
    required this.rank,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.icon,
  });
}

class Achievement {
  final AchievementDefinition definition;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.definition,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory Achievement.fromFirestore(
    AchievementDefinition def,
    Map<String, dynamic> data,
  ) {
    return Achievement(
      definition: def,
      isUnlocked: true,
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate(),
    );
  }

  Achievement copyAsUnlocked(DateTime at) => Achievement(
        definition: definition,
        isUnlocked: true,
        unlockedAt: at,
      );
}

// ─── All achievement definitions ─────────────────────────────────────────────

const List<AchievementDefinition> kAchievementDefinitions = [
  // Total Workouts
  AchievementDefinition(
    id: 'workouts_bronze',
    category: AchievementCategory.totalWorkouts,
    rank: AchievementRank.bronze,
    title: 'Getting Started',
    description: 'Complete 10 workouts',
    targetValue: 10,
    icon: '🏋️',
  ),
  AchievementDefinition(
    id: 'workouts_silver',
    category: AchievementCategory.totalWorkouts,
    rank: AchievementRank.silver,
    title: 'Consistent Athlete',
    description: 'Complete 50 workouts',
    targetValue: 50,
    icon: '🏋️',
  ),
  AchievementDefinition(
    id: 'workouts_gold',
    category: AchievementCategory.totalWorkouts,
    rank: AchievementRank.gold,
    title: 'Workout Legend',
    description: 'Complete 100 workouts',
    targetValue: 100,
    icon: '🏋️',
  ),

  // Streak Milestones
  AchievementDefinition(
    id: 'streak_bronze',
    category: AchievementCategory.streakMilestone,
    rank: AchievementRank.bronze,
    title: 'Week Warrior',
    description: 'Reach a 7-day streak',
    targetValue: 7,
    icon: '🔥',
  ),
  AchievementDefinition(
    id: 'streak_silver',
    category: AchievementCategory.streakMilestone,
    rank: AchievementRank.silver,
    title: 'Monthly Master',
    description: 'Reach a 30-day streak',
    targetValue: 30,
    icon: '🔥',
  ),
  AchievementDefinition(
    id: 'streak_gold',
    category: AchievementCategory.streakMilestone,
    rank: AchievementRank.gold,
    title: 'Century Streak',
    description: 'Reach a 100-day streak',
    targetValue: 100,
    icon: '🔥',
  ),

  // Exercise Mastery (total reps)
  AchievementDefinition(
    id: 'reps_bronze',
    category: AchievementCategory.exerciseMastery,
    rank: AchievementRank.bronze,
    title: 'First Steps',
    description: 'Complete 100 total reps',
    targetValue: 100,
    icon: '💪',
  ),
  AchievementDefinition(
    id: 'reps_silver',
    category: AchievementCategory.exerciseMastery,
    rank: AchievementRank.silver,
    title: 'Iron Will',
    description: 'Complete 500 total reps',
    targetValue: 500,
    icon: '💪',
  ),
  AchievementDefinition(
    id: 'reps_gold',
    category: AchievementCategory.exerciseMastery,
    rank: AchievementRank.gold,
    title: 'Rep Master',
    description: 'Complete 1000 total reps',
    targetValue: 1000,
    icon: '💪',
  ),

  // Programs Completed
  AchievementDefinition(
    id: 'programs_bronze',
    category: AchievementCategory.programsCompleted,
    rank: AchievementRank.bronze,
    title: 'Program Starter',
    description: 'Complete 1 program',
    targetValue: 1,
    icon: '📋',
  ),
  AchievementDefinition(
    id: 'programs_silver',
    category: AchievementCategory.programsCompleted,
    rank: AchievementRank.silver,
    title: 'Program Adept',
    description: 'Complete 5 programs',
    targetValue: 5,
    icon: '📋',
  ),
  AchievementDefinition(
    id: 'programs_gold',
    category: AchievementCategory.programsCompleted,
    rank: AchievementRank.gold,
    title: 'Program Champion',
    description: 'Complete 10 programs',
    targetValue: 10,
    icon: '📋',
  ),
];
