enum StatusEnum { in_progress, skipped, completed, failed }

StatusEnum getStatusFromString(String status) {
  switch (status) {
    case "completed":
      return StatusEnum.completed;
    case "in_progress":
      return StatusEnum.in_progress;
    case "skipped":
      return StatusEnum.skipped;

    default:
      return StatusEnum.failed;
  }
}
