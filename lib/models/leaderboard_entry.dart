class LeaderboardEntry {
  final String userId;
  final String username;
  final String? photoUrl;
  final int value;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.value,
    required this.rank,
    required this.isCurrentUser,
    this.photoUrl,
  });
}
