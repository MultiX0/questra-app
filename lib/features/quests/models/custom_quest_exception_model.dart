class CustomQuestExceptionModel {
  final int count;
  final DateTime latest_date;
  CustomQuestExceptionModel({
    required this.count,
    required this.latest_date,
  });

  CustomQuestExceptionModel copyWith({
    int? count,
    DateTime? latest_date,
  }) {
    return CustomQuestExceptionModel(
      count: count ?? this.count,
      latest_date: latest_date ?? this.latest_date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'count': count,
      'latest_date': latest_date.millisecondsSinceEpoch,
    };
  }

  factory CustomQuestExceptionModel.fromMap(Map<String, dynamic> map) {
    return CustomQuestExceptionModel(
      count: map['count'] ?? 0,
      latest_date: map['latest_date'] != null
          ? DateTime.parse(map['latest_date'])
          : DateTime.now().subtract(const Duration(hours: 1)),
    );
  }

  @override
  String toString() => 'CustomQuestExceptionModel(count: $count, latest_date: $latest_date)';

  @override
  bool operator ==(covariant CustomQuestExceptionModel other) {
    if (identical(this, other)) return true;

    return other.count == count && other.latest_date == latest_date;
  }

  @override
  int get hashCode => count.hashCode ^ latest_date.hashCode;
}
