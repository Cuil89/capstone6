/// Model untuk obat/medicine
class Drug {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final List<String> indications; // Indikasi (symptom IDs atau kondisi)
  final List<String> activeIngredients;
  final String dosageForm; // tablet, capsule, liquid, etc.
  final String? sideEffects;
  final String? warnings;
  final bool isPrescriptionRequired;

  const Drug({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.indications,
    required this.activeIngredients,
    required this.dosageForm,
    this.sideEffects,
    this.warnings,
    this.isPrescriptionRequired = false,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      indications: List<String>.from(json['indications'] as List),
      activeIngredients: List<String>.from(json['activeIngredients'] as List),
      dosageForm: json['dosageForm'] as String,
      sideEffects: json['sideEffects'] as String?,
      warnings: json['warnings'] as String?,
      isPrescriptionRequired: json['isPrescriptionRequired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'description': description,
      'indications': indications,
      'activeIngredients': activeIngredients,
      'dosageForm': dosageForm,
      'sideEffects': sideEffects,
      'warnings': warnings,
      'isPrescriptionRequired': isPrescriptionRequired,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Drug && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
