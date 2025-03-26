import 'dart:developer';

import 'package:questra_app/core/enums/friends_status_enum.dart';
import 'package:questra_app/features/friends/models/friend_request_model.dart';
import 'package:questra_app/features/friends/models/friendship_model.dart';
import 'package:questra_app/features/friends/providers/friends_provider.dart';
import 'package:questra_app/features/friends/providers/friends_requests_provider.dart';
import 'package:questra_app/features/friends/providers/providers.dart';
import 'package:questra_app/features/notifications/controller/notifications_controller.dart';
import 'package:questra_app/imports.dart';

final friendsRepositoryProvider = Provider<FriendsRepository>((ref) => FriendsRepository(ref: ref));

class FriendsRepository {
  final Ref _ref;
  FriendsRepository({required Ref ref}) : _ref = ref;

  SupabaseClient get _client => _ref.watch(supabaseProvider);
  SupabaseQueryBuilder get _friendsRequestsTable => _client.from(TableNames.friend_requests);
  SupabaseQueryBuilder get _friendshipTable => _client.from(TableNames.friendship);
  SupabaseQueryBuilder get _playersTable => _client.from(TableNames.players);
  bool get isArabic => _ref.watch(localeProvider).languageCode == 'ar';

  Future<void> _sendNotification({
    required String arTitle,
    required String enTitle,
    required String arContent,
    required String enContent,
    required String userId,
  }) async {
    try {
      if (isArabic) {
        await NotificationsController.sendNotificaction(
          userId: userId,
          content: arContent,
          title: arTitle,
        );
        return;
      }
      await NotificationsController.sendNotificaction(
        userId: userId,
        content: enContent,
        title: enTitle,
      );
    } catch (e, trace) {
      log(e.toString(), stackTrace: trace);
      return;
    }
  }

  Future<void> sendFriendRequest(FriendRequestModel request) async {
    try {
      final me = _ref.read(authStateProvider)!;
      final _request = await getFriendRequest(user1: request.senderId, user2: request.receiverId);
      log("the request is: ${_request?.toMap()}");
      if (_request == null) {
        await _friendsRequestsTable.insert(request.toMap());
        await _sendNotification(
          userId: request.receiverId,
          arContent: "لديك طلب صداقة جديد",
          arTitle: "لقد قام أحد اللاعبين بارسال طلب صداقة لك",
          enTitle: "New friend request",
          enContent: "check your friend requests in the app",
        );
        return;
      }

      if (_request.status == FriendsStatusEnum.pending && request.senderId == me.id) {
        await _cancelFriendRequest(_request);
        return;
      }

      if (_request.status == FriendsStatusEnum.pending && request.senderId != me.id) {
        CustomToast.systemToast(
          isArabic
              ? "هذا المستخدم قد قام بارسال طلب صداقة لك قبل أن تقوم أنت بذالك"
              : "This user has sent you a friend request before you did.",
        );
        _ref.read(friendsRequestsProvider.notifier).refresh();
        _ref.read(friendsStateProvider.notifier).refresh(me.id);
        return;
      }

      log(_request.status.name);

      if (_request.status != FriendsStatusEnum.pending &&
          _request.status != FriendsStatusEnum.accepted) {
        final playerName = await _ref
            .read(profileRepositoryProvider)
            .getUserNameById(request.senderId);
        await _sendNotification(
          userId: request.receiverId,
          arContent: "لديك طلب صداقة جديد",
          arTitle: "لقد قام $playerName بارسال طلب صداقة لك",
          enTitle: "New friend request",
          enContent: "$playerName has sent you a friend request.",
        );
      }

      await updateFriendRequest(request.copyWith(id: _request.id));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> _cancelFriendRequest(FriendRequestModel request) async {
    try {
      log("canceling the friend request");
      log("request_id: ${request.id}");
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
      await _friendsRequestsTable.update(request.toMap()).eq(KeyNames.request_id, request.id);
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

      final query = _friendsRequestsTable.select("*");
      final condition1 = query.eq(KeyNames.sender_id, user1).eq(KeyNames.receiver_id, user2);
      final condition2 = query.eq(KeyNames.sender_id, user2).eq(KeyNames.receiver_id, user1);
      var data = await condition1.maybeSingle();
      data ??= await condition2.maybeSingle();

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
      final _recieverUsername = await _ref
          .read(profileRepositoryProvider)
          .getUserNameById(request.receiverId);
      await _sendNotification(
        arContent: 'تم قبول طلب صداقتك من $_recieverUsername! يمكنك الآن التفاعل معه.',
        arTitle: 'تم قبول طلب الصداقة 🎉',
        enContent:
            '$_recieverUsername has accepted your friend request! You can now connect and interact.',
        enTitle: 'Friend Request Accepted 🎉',
        userId: request.senderId,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<FriendshipModel?> getFriend({required String user1, required String user2}) async {
    try {
      final query = _friendshipTable.select("*,${TableNames.friend_requests}(*)");

      // First possible arrangement: user1 is user_id1 and user2 is user_id2
      final condition1 = query.eq(KeyNames.user_id1, user1).eq(KeyNames.user_id2, user2);

      // Second possible arrangement: user2 is user_id1 and user1 is user_id2
      final condition2 = query.eq(KeyNames.user_id1, user2).eq(KeyNames.user_id2, user1);

      // Try to find using first arrangement
      var data = await condition1.maybeSingle();

      // If not found, try second arrangement
      data ??= await condition2.maybeSingle();

      if (data == null) return null;
      return FriendshipModel.fromMap(
        data,
      ).copyWith(requestModel: FriendRequestModel.fromMap(data[TableNames.friend_requests]));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> removeFriend({required String user1, required String user2}) async {
    log("userId1:$user1\nuserId2:$user2");

    try {
      final friendShip = await getFriend(user1: user1, user2: user2);
      log("request details: ${friendShip?.requestModel.toString()}");

      if (friendShip == null) return;
      if (friendShip.requestModel != null) {
        await updateFriendRequest(
          friendShip.requestModel!.copyWith(status: FriendsStatusEnum.removed),
        );
      }

      await _friendshipTable
          .delete()
          .eq(KeyNames.user_id1, friendShip.userId1)
          .eq(KeyNames.user_id2, friendShip.userId2);
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

  Future<bool> _hasActiveRequest({required String senderId, required String reciverId}) async {
    try {
      final data =
          await _friendsRequestsTable
              .select("*")
              .eq(KeyNames.sender_id, senderId)
              .eq(KeyNames.receiver_id, reciverId)
              .eq(KeyNames.status, FriendsStatusEnum.pending.name)
              .maybeSingle();

      return data != null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final user_id = _ref.read(authStateProvider)!.id;
    final activeRequests = _ref.read(usersWithActiveRequestFromMe);

    try {
      final value =
          query.isEmpty
              ? ""
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(query.codeUnitAt(query.length - 1) + 1);
      final data = await _playersTable
          .select('*')
          .gte(KeyNames.username, query.isEmpty ? 0 : query)
          .lt(KeyNames.username, value)
          .neq(KeyNames.id, user_id)
          .limit(5);

      final users = data.map((user) => UserModel.fromMap(user)).toList();
      List<UserModel> activeRequestUsers = [];
      for (final user in users) {
        if (activeRequests.any((u) => u.id == user.id)) continue;
        final _isActive = await _hasActiveRequest(senderId: user_id, reciverId: user.id);
        if (_isActive) {
          activeRequestUsers.add(user);
        }
      }

      _ref.read(usersWithActiveRequestFromMe.notifier).state = activeRequestUsers;

      return users;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
