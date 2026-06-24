class GamificationService {
  static int calculateLevel(int xp) {
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    if (xp < 2100) return 6;
    if (xp < 2800) return 7;
    if (xp < 3600) return 8;
    if (xp < 4500) return 9;
    return 10;
  }

  static int xpForNextLevel(int currentLevel) {
    const thresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500];
    if (currentLevel >= thresholds.length) return 9999;
    return thresholds[currentLevel];
  }

  static int calculateStreak(DateTime lastLogin, DateTime currentLogin, int currentStreak) {
    final last = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
    final curr = DateTime(currentLogin.year, currentLogin.month, currentLogin.day);
    final diff = curr.difference(last).inDays;
    if (diff == 0) return currentStreak;
    if (diff == 1) return currentStreak + 1;
    return 1;
  }

  static List<String> evaluateBadges({
    required int xp,
    required int level,
    required int streak,
    required int quizzesCompleted,
    required List<String> currentBadges,
  }) {
    final badges = Set<String>.from(currentBadges);

    if (xp >= 100) badges.add('first_100_xp');
    if (xp >= 500) badges.add('eco_warrior');
    if (xp >= 1000) badges.add('green_champion');
    if (xp >= 2000) badges.add('earth_guardian');
    if (level >= 3) badges.add('level_3_reached');
    if (level >= 5) badges.add('level_5_reached');
    if (level >= 10) badges.add('max_level');
    if (streak >= 3) badges.add('streak_3');
    if (streak >= 7) badges.add('streak_7');
    if (streak >= 30) badges.add('streak_30');
    if (quizzesCompleted >= 1) badges.add('first_quiz');
    if (quizzesCompleted >= 6) badges.add('all_modules_completed');

    return badges.toList();
  }
}
