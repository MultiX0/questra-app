Duration? parseDuration(String input) {
  input = input.toLowerCase();
  List<String> parts = input.split(' ');
  if (parts.length < 2) {
    throw FormatException('Invalid duration format: $input');
  }

  String numberPart = parts[0];
  String unitPart = parts[1];

  // Map to convert words to numbers
  Map<String, int> numberWords = {
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
    // Extend this map for more words
  };

  int? value;
  if (numberWords.containsKey(numberPart)) {
    value = numberWords[numberPart];
  } else {
    value = int.tryParse(numberPart);
  }

  if (value == null) {
    return null;
    // throw FormatException('Invalid number format: $numberPart');
  }

  if (unitPart.startsWith('hour')) {
    return Duration(hours: value);
  } else if (unitPart.startsWith('minute')) {
    return Duration(minutes: value);
  } else {
    return null;

    // throw FormatException('Unknown time unit: $unitPart');
  }
}
