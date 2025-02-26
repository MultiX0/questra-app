import 'dart:math';

List<int> _rewards = [100, 50, 200, 150, 250, 500, 300, 70, 400, 350, 1000];
int getReward() {
  final rand = Random.secure();
  final reward = _rewards[rand.nextInt(_rewards.length)];
  return reward;
}
