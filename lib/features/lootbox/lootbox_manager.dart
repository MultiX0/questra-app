import 'dart:async';
import 'dart:math';
import 'package:questra_app/core/services/background_service.dart';
import 'package:questra_app/features/lootbox/models/lootbox_model.dart';
import 'package:questra_app/imports.dart';
import 'dart:developer' as dev;

int sessionTimeInSeconds = 0;
Timer? sessionTimer;

void startSessionTimer() {
  sessionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    sessionTimeInSeconds++;
  });
}

void stopSessionTimer() {
  sessionTimer?.cancel();
}

class LootBoxManager {
  final _client = Supabase.instance.client;
  SupabaseQueryBuilder get _lootBoxTable => _client.from(TableNames.loot_boxes);

  Future<bool> unTakenLootBox(String userId) async {
    try {
      final lootBox = await fetchUserLootBoxData();
      if (lootBox.hasTaken) {
        return false;
      }

      return true;
    } catch (e) {
      dev.log(e.toString());
      rethrow;
    }
  }

  Future<void> saveSessionTime() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw 'the user is null';
      }

      await _lootBoxTable
          .update({KeyNames.session_time: sessionTimeInSeconds})
          .eq(KeyNames.user_id, user.id);
    } catch (e) {
      dev.log(e.toString());
      rethrow;
    }
  }

  Future<LootboxModel> fetchUserLootBoxData() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw 'the user is null';
      }

      final data = await _lootBoxTable.select("*").eq(KeyNames.user_id, user.id).maybeSingle();
      if (data == null) {
        return await insertLootBox(user.id);
      }

      return LootboxModel.fromMap(data);
    } catch (e) {
      dev.log(e.toString());
      rethrow;
    }
  }

  Future<LootboxModel> insertLootBox(String userId) async {
    try {
      final newLootBox = LootboxModel(
        id: "",
        userId: userId,
        lastLootBoxTime: DateTime.now(),
        streak: 0,
        totalActions: 0,
        sessionTime: 0,
        createdAt: DateTime.now(),
        hasTaken: true,
      );

      await _lootBoxTable.insert(newLootBox.toMap());
      return newLootBox;
    } catch (e) {
      dev.log(e.toString());
      rethrow;
    }
  }

  Future<bool> checkLootBoxDrop() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return false;

    // Fetch user's loot box data
    final lootBoxData = await fetchUserLootBoxData();

    final lastLootBoxTime = lootBoxData.lastLootBoxTime;
    final streak = lootBoxData.streak;
    final totalActions = lootBoxData.totalActions;
    final sessionTime = lootBoxData.sessionTime;

    final now = DateTime.now();
    final timeSinceLastDrop = now.difference(lastLootBoxTime).inSeconds;

    // Define probability formula
    const double baseProbability = 0.05; // 5% base chance
    final double timeMultiplier = 0.01 * (sessionTime / 60); // +1% per minute of activity
    final double actionMultiplier = 0.02 * (totalActions / 10); // +2% per 10 actions
    final double streakMultiplier = (streak > 5) ? 0.05 : 0.03 * streak; // +5% if streak > 5 days
    const int cooldownTime = 600; // 10 minutes cooldown
    final double randomFactor = Random().nextDouble() * 0.05; // 0% - 5% randomness

    // Calculate probability
    double probability =
        baseProbability + timeMultiplier + actionMultiplier + streakMultiplier + randomFactor;
    probability = probability.clamp(0, 0.5); // Cap at 50%

    // Ensure cooldown is respected
    if (timeSinceLastDrop < cooldownTime) {
      dev.log("Cooldown active. Try again later.");
      return false;
    }

    // Determine if loot box drops
    final bool lootBoxDrops = Random().nextDouble() < probability;

    if (lootBoxDrops) {
      // Update loot box time in Supabase
      await supabase
          .from('loot_boxes')
          .update({KeyNames.last_lootbox_time: now.toIso8601String(), KeyNames.hasTaken: false})
          .eq('user_id', user.id);

      sendNotification("System", "🎉 NEW Loot Box Dropped!");

      dev.log("🎉 Loot Box Dropped!");
      return true;
    } else {
      dev.log("❌ No loot box this time.");
      return false;
    }
  }
}
