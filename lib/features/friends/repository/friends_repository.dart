import 'dart:developer';

import 'package:questra_app/core/enums/friends_status_enum.dart';
import 'package:questra_app/core/shared/constants/function_names.dart';
import 'package:questra_app/features/friends/models/friend_request_model.dart';
import 'package:questra_app/features/friends/models/friendship_model.dart';
import 'package:questra_app/imports.dart';

final friendsRepositoryProvider = Provider<FriendsRepository>((ref) => FriendsRepository(ref: ref));

class FriendsRepository {
  final Ref _ref;
  FriendsRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _friendsRequestsTable => _client.from(TableNames.friend_requests);
  SupabaseQueryBuilder get _friendshipTable => _client.from(TableNames.friendship);

  Future<void> sendFriendRequest(FriendRequestModel request) async {
    try {
      final _request = await getFriendRequest(user1: request.senderId, user2: request.receiverId);
      if (_request == null) {
        await _friendsRequestsTable.insert(request.toMap());
        return;
      }

      if (_request.status == FriendsStatusEnum.rejected) {
        await updateFriendRequest(request);
        return;
      }

      if (_request.status == FriendsStatusEnum.pending) {
        await _cancelFriendRequest(request);
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> _cancelFriendRequest(FriendRequestModel request) async {
    try {
      await _friendsRequestsTable
          .update({KeyNames.status: friendsEnumToString(FriendsStatusEnum.canceled)})
          .eq(KeyNames.request_id, request.id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateFriendRequest(FriendRequestModel request) async {
    try {
      await _friendsRequestsTable
          .update({KeyNames.status: request.status.name})
          .eq(KeyNames.request_id, request.id);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<FriendRequestModel?> getFriendRequest({
    required String user1,
    required String user2,
  }) async {
    try {
      // await
      final data =
          await _friendsRequestsTable
              .select("*")
              .or('${KeyNames.sender_id}.eq.$user1,${KeyNames.receiver_id}.eq.$user1')
              .or('${KeyNames.sender_id}.eq.$user2,${KeyNames.receiver_id}.eq.$user2')
              .maybeSingle();

      if (data == null) return null;

      return FriendRequestModel.fromMap(data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAllFriendRequests({
    required String userId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _friendsRequestsTable
          .select("*")
          .eq(KeyNames.receiver_id, userId)
          .eq(KeyNames.status, FriendsStatusEnum.pending.name)
          .range(startIndex, startIndex + pageSize - 1);

      final requests = data.map((request) => FriendRequestModel.fromMap(request)).toList();
      final ids = requests.map((r) => r.senderId).toList();
      final users = await _ref.read(profileRepositoryProvider).getUsersIn(ids);
      final requestIdByUserId =
          requests
              .map(
                (r) => {
                  KeyNames.sender_id: r.senderId,
                  'data': {KeyNames.request_id: r.id, KeyNames.status: r.status.name},
                },
              )
              .toList();
      return {'users': users.map((user) => user.toMap()).toList(), 'ids': requestIdByUserId};
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  List<String> _getOtherUserIds(List<FriendshipModel> _friendships, String myUserId) {
    List<String> otherUserIds = [];

    for (var record in _friendships) {
      if (record.userId1 != myUserId) {
        otherUserIds.add(record.userId1);
      }

      if (record.userId2 != myUserId) {
        otherUserIds.add(record.userId2);
      }
    }

    return otherUserIds;
  }

  Future<List<UserModel>> getAllFriends({
    required String userId,
    required int startIndex,
    required int pageSize,
  }) async {
    try {
      final data = await _friendshipTable
          .select("*")
          .or('${KeyNames.user_id1}.eq.$userId,${KeyNames.user_id2}.eq.$userId')
          .range(startIndex, startIndex + pageSize - 1);

      final _friendships = data.map((f) => FriendshipModel.fromMap(f)).toList();
      List<String> usersIds = _getOtherUserIds(_friendships, userId);

      return await _ref.read(profileRepositoryProvider).getUsersIn(usersIds);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> insertFriendShip({required FriendRequestModel request}) async {
    try {
      final friendShip = FriendshipModel(
        userId1: request.senderId,
        userId2: request.receiverId,
        requestId: request.id,
        createdAt: DateTime.now(),
      );
      await _friendshipTable.insert(friendShip.toMap());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> accpetFriendRequest(FriendRequestModel request) async {
    try {
      await updateFriendRequest(request.copyWith(status: FriendsStatusEnum.accepted));
      await insertFriendShip(request: request);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<FriendshipModel?> getFriend({required String user1, required String user2}) async {
    try {
      final data =
          await _friendshipTable
              .select("*")
              .or('${KeyNames.sender_id}.eq.$user1,${KeyNames.receiver_id}.eq.$user1')
              .or('${KeyNames.sender_id}.eq.$user2,${KeyNames.receiver_id}.eq.$user2')
              .maybeSingle();

      if (data == null) return null;
      return FriendshipModel.fromMap(data);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> removeFriend({required String user1, required String user2}) async {
    try {
      final friendShip = await getFriend(user1: user1, user2: user2);
      if (friendShip == null) return;
      await _friendshipTable
          .delete()
          .or('${KeyNames.sender_id}.eq.$user1,${KeyNames.receiver_id}.eq.$user1')
          .or('${KeyNames.sender_id}.eq.$user2,${KeyNames.receiver_id}.eq.$user2');
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<int> getFriendsCount(String userId) async {
    try {
      final count = await _client.rpc(
        FunctionNames.get_friends_count,
        params: {'user_uuid': userId},
      );

      return count ?? 0;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<int> getFriendRequestsCount(String userId) async {
    try {
      final count = await _client.rpc(
        FunctionNames.get_friend_requests_count,
        params: {'user_uuid': userId},
      );

      return count ?? 0;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
