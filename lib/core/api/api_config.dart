class ApiConfig {
  ApiConfig._();

  static const String defaultBaseUrl =
      'https://tomasa-ridiculous-klara.ngrok-free.dev';

  static const String baseUrl = String.fromEnvironment(
    'SMART_FARMASI_API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );

  static Uri endpoint(String path, [Map<String, dynamic>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalizedPath');
    if (query == null || query.isEmpty) return uri;

    final cleanQuery = query.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    )..removeWhere((_, value) => value.isEmpty);

    return uri.replace(
      queryParameters: {...uri.queryParameters, ...cleanQuery},
    );
  }

  static String proxiedImageUrl(String imageUrl) {
    if (imageUrl.trim().isEmpty) return '';
    return endpoint('/api/disease-news/image', {
      'url': imageUrl.trim(),
    }).toString();
  }

  static String absoluteUrl(String pathOrUrl) {
    final value = pathOrUrl.trim();
    if (value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;
    return endpoint(value).toString();
  }

  static bool get usesNgrok =>
      Uri.tryParse(baseUrl)?.host.contains('ngrok') ?? false;
}
