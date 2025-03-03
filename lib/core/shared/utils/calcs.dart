import 'package:questra_app/core/shared/utils/between.dart';

int calculateHigherXpForLevel(int level) {
  return (100 * (level * level) - (200 * level) + 400).toInt();
}

int calculateXpForLevel(int level) {
  if (level >= 20) {
    return calculateHigherXpForLevel(level);
  }
  return (100 * (level * level) - (200 * level) + 400).toInt();
}

int questXp(int level, String difficulty) {
  int xpForLevel = calculateXpForLevel(level);
  final diff = difficulty.toLowerCase();
  if (diff.contains('easy')) {
    return (xpForLevel * 0.1).toInt();
  } else if (diff.contains('medium')) {
    return (xpForLevel * 0.2).toInt();
  } else {
    return (xpForLevel * 0.4).toInt();
  }
}

int calculateQuestCoins(int level, String difficulty) {
  int baseCoins = 50; // A base value for coins that can be adjusted as needed
  final diff = difficulty.toLowerCase();
  if (diff.contains('easy')) {
    return (baseCoins * level * 0.3).toInt(); // Easy quests give 50% of base
  } else if (diff.contains('medium')) {
    return (baseCoins * level * 0.8).toInt(); // Medium quests give full base
  } else {
    return (baseCoins * level * 1).toInt(); // Hard quests give 150% of base
  }
}

Map<String, int> addXp(int xp, Map<String, int> currentData) {
  int currentXp = currentData['xp'] ?? 0;
  int currentLevel = currentData['level'] ?? 1;

  currentXp += xp;

  while (currentXp >= calculateXpForLevel(currentLevel)) {
    currentXp -= calculateXpForLevel(currentLevel);
    currentLevel++;
  }

  return {"xp": currentXp, "level": currentLevel};
}

int calcEventRegisterationFee(int level) {
  int baseCoins = 50;
  if (isBetween(level, 1, 5)) {
    return baseCoins * 2;
  }

  if (isBetween(level, 5, 10)) {
    return baseCoins * 10;
  }

  if (isBetween(level, 10, 20)) {
    return baseCoins * 100;
  }

  if (isBetween(level, 20, 40)) {
    return baseCoins * 200;
  }

  return baseCoins * 500;
}

// class Player {
//   int level = 1;
//   int currentXp = 0;

//   void addXp(int xp) {
//     currentXp += xp;
//     while (currentXp >= calculateXpForLevel(level)) {
//       currentXp -= calculateXpForLevel(level);
//       levelUp();
//     }
//   }

//   void levelUp() {
//     level++;
//     print('Congratulations! You leveled up to $level!');
//   }
// }
