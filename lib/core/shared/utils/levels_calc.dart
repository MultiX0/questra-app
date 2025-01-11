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
  switch (difficulty.toLowerCase()) {
    case 'easy':
      return (xpForLevel * 0.1).toInt();
    case 'medium':
      return (xpForLevel * 0.3).toInt();
    case 'hard':
      return (xpForLevel * 0.6).toInt();
    default:
      return 0;
  }
}

int calculateQuestCoins(int level, String difficulty) {
  int baseCoins = 50; // A base value for coins that can be adjusted as needed
  switch (difficulty.toLowerCase()) {
    case 'easy':
      return (baseCoins * level * 0.5).toInt(); // Easy quests give 50% of base
    case 'medium':
      return (baseCoins * level * 1.0).toInt(); // Medium quests give full base
    case 'hard':
      return (baseCoins * level * 1.5).toInt(); // Hard quests give 150% of base
    default:
      return 0; // Default for invalid difficulty
  }
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
