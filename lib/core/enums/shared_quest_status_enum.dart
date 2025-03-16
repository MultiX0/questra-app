enum SharedQuestStatusEnum { pending, accepted, rejected }

String sharedQuestStatusToString(SharedQuestStatusEnum status) {
  return status.name;
}

SharedQuestStatusEnum sharedQuestStatusFromString(String status) {
  return SharedQuestStatusEnum.values.firstWhere(
    (e) => e.name == status,
    orElse: () => SharedQuestStatusEnum.pending,
  );
}
