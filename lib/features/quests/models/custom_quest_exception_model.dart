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
      count: map['count'] as int,
      latest_date: DateTime.fromMillisecondsSinceEpoch(map['latest_date'] as int),
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
