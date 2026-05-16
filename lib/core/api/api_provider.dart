import 'package:get/get.dart';

import 'api_config.dart';

class ApiProvider extends GetConnect {
  static String get apiBaseUrl => ApiConfig.baseUrl;

  static String proxiedImageUrl(String imageUrl) {
    return ApiConfig.proxiedImageUrl(imageUrl);
  }

  static Map<String, dynamic> bodyAsMap(Response response) {
    final body = response.body;
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    return <String, dynamic>{};
  }

  static bool boolValue(Response response, String key) {
    return bodyAsMap(response)[key] == true;
  }

  static String stringValue(
    Response response,
    String key, [
    String fallback = '',
  ]) {
    final value = bodyAsMap(response)[key];
    return value == null ? fallback : value.toString();
  }

  static String messageFromResponse(
    Response? response, {
    String fallback = 'Terjadi kesalahan. Silakan coba lagi.',
  }) {
    if (response == null || response.status.connectionError) {
      return 'Server tidak dapat dihubungi. Pastikan internet aktif, backend berjalan, dan URL ngrok masih valid.';
    }

    final body = response.body;
    if (body is Map) {
      final message = body['message'] ?? body['error'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (body is String) {
      final lowerBody = body.toLowerCase();
      if (lowerBody.contains('ngrok') || lowerBody.contains('<html')) {
        return 'Server tidak dapat dihubungi melalui ngrok. Periksa URL ngrok dan pastikan backend aktif.';
      }
    }

    switch (response.statusCode) {
      case 400:
        return 'Data yang dikirim belum valid.';
      case 401:
        return 'Sesi atau kredensial tidak valid. Silakan login ulang.';
      case 403:
        return 'Akses ditolak atau akun belum diverifikasi.';
      case 404:
        return 'Endpoint server tidak ditemukan.';
      case 408:
      case 504:
        return 'Koneksi ke server timeout. Coba lagi beberapa saat.';
      case 500:
      case 502:
      case 503:
        return 'Server sedang bermasalah atau tidak aktif.';
      default:
        return fallback;
    }
  }

  @override
  void onInit() {
    httpClient.baseUrl = ApiConfig.baseUrl;
    httpClient.timeout = const Duration(seconds: 15);
    httpClient.defaultContentType = 'application/json';

    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.headers['Accept'] = 'application/json';
      return request;
    });

    super.onInit();
  }

  // Register
  Future<Response> register(
    String name,
    String email,
    String password,
    String? firebaseUid,
  ) {
    return post('/api/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'firebase_uid': firebaseUid ?? '',
    });
  }

  Future<Response> verifyOtp(String email, String otpCode) {
    return post('/api/verify-otp', {'email': email, 'otp_code': otpCode});
  }

  Future<Response> resendOtp(String email) {
    return post('/api/resend-otp', {'email': email});
  }

  Future<Response> forgotPassword(String email) {
    return post('/api/forgot-password', {'email': email});
  }

  Future<Response> resetPassword(
    String email,
    String otpCode,
    String password,
    String passwordConfirmation,
  ) {
    return post('/api/reset-password', {
      'email': email,
      'otp_code': otpCode,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<Response> requestAppPassword(String email) {
    return post('/api/request-app-password', {'email': email});
  }

  Future<Response> verifyAppPasswordOtp(String email, String otpCode) {
    return post('/api/verify-app-password-otp', {
      'email': email,
      'otp_code': otpCode,
    });
  }

  Future<Response> setAppPassword(
    String email,
    String setupToken,
    String password,
    String passwordConfirmation,
  ) {
    return post('/api/set-app-password', {
      'email': email,
      'setup_token': setupToken,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<Response> requestEmailChange(
    String token,
    String newEmail,
    String currentPassword,
  ) {
    return post(
      '/api/account/request-email-change',
      {'new_email': newEmail, 'current_password': currentPassword},
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Response> confirmEmailChange(
    String token,
    String newEmail,
    String otpCode,
  ) {
    return post(
      '/api/account/confirm-email-change',
      {'new_email': newEmail, 'otp_code': otpCode},
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Response> requestPasswordChange(
    String token,
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) {
    return post(
      '/api/account/request-password-change',
      {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Response> confirmPasswordChange(
    String token,
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
    String otpCode,
  ) {
    return post(
      '/api/account/confirm-password-change',
      {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
        'otp_code': otpCode,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Response> requestDeleteAccountOtp(String token) {
    return post(
      '/api/account/request-delete-otp',
      {},
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Response> confirmDeleteAccount({
    required String token,
    String? password,
    String? otpCode,
  }) {
    return post(
      '/api/account/delete',
      {
        'password': password,
        'otp_code': otpCode,
      },
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Response> reactivateAccount({
    required String email,
    String? password,
    String? googleToken,
  }) {
    return post('/api/account/reactivate', {
      'email': email,
      'password': password,
      'google_token': googleToken,
    });
  }

  // Login
  Future<Response> login(String email, String password) {
    return post('/api/login', {'email': email, 'password': password});
  }

  // Login with Google
  Future<Response> loginWithGoogle(
    String idToken,
    String email,
    String name,
    String? firebaseUid,
  ) {
    return post('/api/login/google', {
      'id_token': idToken,
      'email': email,
      'name': name,
      'firebase_uid': firebaseUid ?? '',
    });
  }

  // Get Profile
  Future<Response> getProfile(String token) {
    return get('/api/profile', headers: {'Authorization': 'Bearer $token'});
  }

  Future<Response> updateProfile(String token, {required String name}) {
    return put(
      '/api/profile',
      {'name': name},
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Response> uploadProfilePhoto({
    required String token,
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) {
    final form = FormData({
      'photo': MultipartFile(
        bytes,
        filename: filename,
        contentType: contentType,
      ),
    });

    return post(
      '/api/profile/photo',
      form,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Response> deleteProfilePhoto(String token) {
    return delete(
      '/api/profile/photo',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  // ─── Disease News ───────────────────────────
  Future<Response> getDiseaseNewsTrending() {
    return get('/api/disease-news/trending');
  }

  Future<Response> getDiseaseNewsList({
    int page = 1,
    int perPage = 10,
    String? search,
    String? source,
    String? alertLevel,
    String? country,
    String? region,
    String sort = 'latest',
  }) {
    final Map<String, dynamic> query = {
      'page': page.toString(),
      'per_page': perPage.toString(),
      'sort': sort,
      if (search != null && search.isNotEmpty) 'search': search,
      if (source != null && source.isNotEmpty) 'source': source,
      if (alertLevel != null && alertLevel.isNotEmpty)
        'alert_level': alertLevel,
      if (country != null && country.isNotEmpty) 'country': country,
      if (region != null && region.isNotEmpty) 'region': region,
    };
    return get('/api/disease-news', query: query);
  }

  Future<Response> refreshDiseaseNews() {
    return post('/api/disease-news/refresh', {});
  }

  // ─── Chatbot ────────────────────────────────
  Future<Response> getChatbotResponse(String token, String message) {
    return post(
      '/api/chatbot',
      {'message': message},
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
