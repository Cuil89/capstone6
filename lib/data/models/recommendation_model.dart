import 'drug_model.dart';

/// Model untuk rekomendasi obat berdasarkan gejala
class Recommendation {
  final String id;
  final List<String> symptomIds;
  final List<RecommendationItem> items;
  final DateTime createdAt;

  const Recommendation({
    required this.id,
    required this.symptomIds,
    required this.items,
    required this.createdAt,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      symptomIds: List<String>.from(json['symptomIds'] as List),
      items: (json['items'] as List)
          .map((item) => RecommendationItem.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symptomIds': symptomIds,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Model untuk item rekomendasi (obat dengan tingkat relevansi)
class RecommendationItem {
  final Drug drug;
  final double confidenceScore; // 0.0 - 1.0
  final String? reason; // Alasan rekomendasi
  final List<String> matchingSymptoms; // Gejala yang cocok

  const RecommendationItem({
    required this.drug,
    required this.confidenceScore,
    this.reason,
    required this.matchingSymptoms,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      drug: Drug.fromJson(json['drug'] as Map<String, dynamic>),
      confidenceScore: json['confidenceScore'] as double,
      reason: json['reason'] as String?,
      matchingSymptoms: List<String>.from(json['matchingSymptoms'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drug': drug.toJson(),
      'confidenceScore': confidenceScore,
      'reason': reason,
      'matchingSymptoms': matchingSymptoms,
    };
  }
}
