int calculateXpForLevel(int level) {
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
