Duration parseDuration(String input) {
  // Normalize input
  input = input.toLowerCase().trim();

  // Check for fractional component ("and a half")
  bool hasHalf = input.contains('and a half');
  if (hasHalf) {
    // Remove the fractional text so we can easily extract the number and unit.
    input = input.replaceAll('and a half', '');
  }

  // Split by whitespace.
  List<String> parts = input.split(RegExp(r'\s+'));
  if (parts.length < 2) {
    throw FormatException('Invalid duration format: $input');
  }

  // The first part should be the number and the last part the unit.
  String numberPart = parts.first;
  String unitPart = parts.last;

  // Map to convert word numbers to their numeric values.
  Map<String, double> numberWords = {
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    // Extend this map as needed.
  };

  double baseValue;
  if (numberWords.containsKey(numberPart)) {
    baseValue = numberWords[numberPart]!;
  } else {
    baseValue = double.tryParse(numberPart) ??
        (throw FormatException('Invalid number format: $numberPart'));
  }

  // Add 0.5 if the fraction "and a half" was present.
  if (hasHalf) {
    baseValue += 0.5;
  }

  // Convert the duration to seconds.
  int totalSeconds;
  if (unitPart.startsWith('hour')) {
    totalSeconds = (baseValue * 3600).round();
  } else if (unitPart.startsWith('minute')) {
    totalSeconds = (baseValue * 60).round();
  } else {
    throw FormatException('Unknown time unit: $unitPart');
  }

  return Duration(seconds: totalSeconds);
}
