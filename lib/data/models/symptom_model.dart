/// Model untuk gejala/gejala kesehatan
class Symptom {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final String? description;

  const Symptom({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    this.description,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'category': category,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Symptom && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
