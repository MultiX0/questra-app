enum FriendsStatusEnum { pending, accepted, rejected, canceled, removed }

String friendsEnumToString(FriendsStatusEnum _enum) {
  switch (_enum) {
    case FriendsStatusEnum.accepted:
      return FriendsStatusEnum.accepted.name;
    case FriendsStatusEnum.canceled:
      return FriendsStatusEnum.canceled.name;
    case FriendsStatusEnum.pending:
      return FriendsStatusEnum.pending.name;
    case FriendsStatusEnum.rejected:
      return FriendsStatusEnum.rejected.name;
    case FriendsStatusEnum.removed:
      return FriendsStatusEnum.removed.name;
  }
}

FriendsStatusEnum friendsEnumStringToEnum(String _enum) {
  switch (_enum) {
    case 'accepted':
      return FriendsStatusEnum.accepted;
    case 'canceled':
      return FriendsStatusEnum.canceled;
    case 'pending':
      return FriendsStatusEnum.pending;
    case 'rejected':
      return FriendsStatusEnum.rejected;
    default:
      return FriendsStatusEnum.removed;
  }
}
