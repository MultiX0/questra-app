double totalXpBarWidth({
  required double current,
  required double max,
  required double width,
}) {
  double val = (current / max) * width;
  return val;
}
