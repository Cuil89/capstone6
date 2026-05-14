import 'package:get/get.dart';

class ApiProvider extends GetConnect {
  static const String apiBaseUrl =
      'https://tomasa-ridiculous-klara.ngrok-free.dev';
  static const String localWebBaseUrl = 'http://127.0.0.1:5000';

  static String proxiedImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    final encoded = Uri.encodeQueryComponent(imageUrl);
    final host = Uri.base.host;
    final isLocalWeb = host == 'localhost' || host == '127.0.0.1';
    final baseUrl = isLocalWeb ? localWebBaseUrl : apiBaseUrl;
    return '$baseUrl/api/disease-news/image?url=$encoded';
  }

  @override
  void onInit() {
    // === PILIH SALAH SATU URL DI BAWAH INI ===

    // 1. Opsi Ngrok (Gunakan ini agar tidak perlu ganti-ganti IP)
    // TODO: Ganti URL di bawah ini dengan URL ngrok kamu yang aktif
    const String baseUrl = apiBaseUrl;

    // 2. Opsi IP Lokal Laptop (IP yang sekarang: 192.168.1.7)
    // const String baseUrl = 'http://192.168.1.7:5000';

    // 3. Opsi Emulator Android (Khusus jika pakai emulator bawaan Android Studio)
    // const String baseUrl = 'http://10.0.2.2:5000';

    // 4. Opsi Localhost (Khusus untuk Flutter Web / Chrome)
    // const String baseUrl = 'http://127.0.0.1:5000';

    httpClient.baseUrl = baseUrl;
    httpClient.timeout = const Duration(seconds: 15);

    // Bypass Ngrok Browser Warning
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['ngrok-skip-browser-warning'] = 'true';
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
}
