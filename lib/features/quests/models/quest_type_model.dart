import '../../../core/shared/constants/key_names.dart';

class QuestTypeModel {
  final int id;
  final String name;
  final String description;
  QuestTypeModel({
    required this.id,
    required this.name,
    required this.description,
  });

  QuestTypeModel copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return QuestTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.id: id,
      KeyNames.name: name,
      KeyNames.description: description,
    };
  }

  factory QuestTypeModel.fromMap(Map<String, dynamic> map) {
    return QuestTypeModel(
      id: map[KeyNames.id] ?? -1,
      name: map[KeyNames.name] ?? "",
      description: map[KeyNames.description] ?? "",
    );
  }

  @override
  String toString() => 'QuestTypeModel(id: $id, name: $name, description: $description)';

  @override
  bool operator ==(covariant QuestTypeModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.description == description;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode;
}
