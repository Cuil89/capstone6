class DiseaseNewsModel {
  final int id;
  final String title;
  final String diseaseName;
  final String summary;
  final String country;
  final String sourceName;
  final String sourceUrl;
  final String imageUrl;
  final String alertLevel; // 'low' | 'medium' | 'high'
  final String
  badge; // 'Trending' | 'Wabah Global' | 'Update Terbaru' | 'Perlu Diwaspadai'
  final String regionScope; // 'indonesia' | 'international'
  final int trendScore;
  final String trendKeyword;
  final bool isTrending;
  final int viewCount;
  final DateTime? publishedAt;
  final DateTime? fetchedAt;

  DiseaseNewsModel({
    required this.id,
    required this.title,
    required this.diseaseName,
    required this.summary,
    required this.country,
    required this.sourceName,
    required this.sourceUrl,
    required this.imageUrl,
    required this.alertLevel,
    required this.badge,
    required this.regionScope,
    required this.trendScore,
    required this.trendKeyword,
    required this.isTrending,
    required this.viewCount,
    this.publishedAt,
    this.fetchedAt,
  });

  factory DiseaseNewsModel.fromJson(Map<String, dynamic> json) {
    return DiseaseNewsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      diseaseName: json['disease_name'] ?? '',
      summary: json['summary'] ?? '',
      country: json['country'] ?? '',
      sourceName: json['source_name'] ?? '',
      sourceUrl: json['source_url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      alertLevel: json['alert_level'] ?? 'low',
      badge: json['badge'] ?? 'Update Terbaru',
      regionScope: json['region_scope'] ?? 'international',
      trendScore: (json['trend_score'] as num?)?.round() ?? 0,
      trendKeyword: json['trend_keyword'] ?? '',
      isTrending: json['is_trending'] ?? false,
      viewCount: json['view_count'] ?? 0,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'])
          : null,
      fetchedAt: json['fetched_at'] != null
          ? DateTime.tryParse(json['fetched_at'])
          : null,
    );
  }

  /// Tanggal terformat Indonesia
  String get formattedDate {
    final dt = publishedAt ?? fetchedAt;
    if (dt == null) return 'Tidak diketahui';
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String get regionLabel {
    return regionScope == 'indonesia' ? 'Indonesia' : 'Internasional';
  }
}
