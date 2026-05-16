import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/routes/app_routes.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/theme/app_theme.dart';

class AuthController extends GetxController {
  ApiProvider get _apiProvider => Get.find<ApiProvider>();

  // Global auth state
  var isLogin = false.obs;
  var token = ''.obs;
  var userData = {}.obs;

  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmController = TextEditingController();
  final otpController = TextEditingController();

  // Form States
  var obscurePassword = true.obs;
  var obscureConfirm = true.obs;
  var isLoading = false.obs;
  var isVerifyLoading = false.obs;
  var isResendLoading = false.obs;
  var agreedToTerms = false.obs;
  var pendingVerificationEmail = ''.obs;
  var lastOtpExpiresIn = 180.obs;
  var lastOtpResendAvailableIn = 180.obs;

  // Validation Errors
  var emailError = ''.obs;
  var passwordError = ''.obs;
  var confirmError = ''.obs;
  var nameError = ''.obs;
  var otpError = ''.obs;
  var isGoogleLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Map<String, dynamic> _body(Response response) =>
      ApiProvider.bodyAsMap(response);

  String _message(
    Response response, {
    String fallback = 'Terjadi kesalahan. Silakan coba lagi.',
  }) {
    return ApiProvider.messageFromResponse(response, fallback: fallback);
  }

  String _connectionMessage([Object? error]) {
    return 'Server tidak dapat dihubungi. Pastikan internet aktif, backend berjalan, dan URL ngrok masih valid.';
  }

  int _intFromBody(Map<String, dynamic> body, String key, int fallback) {
    final value = body[key];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  void _updateOtpTimingFromBody(Map<String, dynamic> body) {
    lastOtpExpiresIn.value = _intFromBody(body, 'expires_in', 180);
    lastOtpResendAvailableIn.value = _intFromBody(
      body,
      'resend_available_in',
      180,
    );
  }

  String _googleErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'network-request-failed':
          return 'Koneksi internet bermasalah saat menghubungi Google.';
        case 'account-exists-with-different-credential':
          return 'Email ini sudah terhubung dengan metode login lain.';
        case 'invalid-credential':
          return 'Token Google tidak valid. Silakan coba login ulang.';
        default:
          return error.message ?? 'Login Google gagal. Silakan coba lagi.';
      }
    }
    if (error is PlatformException) {
      if (error.code == 'sign_in_failed') {
        return 'Login Google gagal. Pastikan SHA-1/SHA-256 debug dan release sudah terdaftar di Firebase.';
      }
      if (error.code == 'network_error') {
        return 'Koneksi internet bermasalah saat login Google.';
      }
      return error.message ?? 'Login Google gagal. Silakan coba lagi.';
    }
    return 'Login Google gagal. Periksa koneksi internet dan konfigurasi Firebase.';
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;
  void toggleConfirmVisibility() =>
      obscureConfirm.value = !obscureConfirm.value;
  void toggleTermsAgreement() => agreedToTerms.value = !agreedToTerms.value;

  bool validateEmail() {
    if (emailController.text.trim().isEmpty) {
      emailError.value = 'Email tidak boleh kosong';
      return false;
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text)) {
      emailError.value = 'Format email tidak valid';
      return false;
    } else {
      emailError.value = '';
      return true;
    }
  }

  bool validatePassword() {
    if (passwordController.text.isEmpty) {
      passwordError.value = 'Password tidak boleh kosong';
      return false;
    } else if (passwordController.text.length < 8) {
      passwordError.value = 'Password minimal 8 karakter';
      return false;
    } else {
      passwordError.value = '';
      return true;
    }
  }

  bool validateName() {
    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Nama tidak boleh kosong';
      return false;
    } else if (nameController.text.trim().length < 3) {
      nameError.value = 'Nama minimal 3 karakter';
      return false;
    } else {
      nameError.value = '';
      return true;
    }
  }

  bool validateConfirmPassword() {
    if (confirmController.text.isEmpty) {
      confirmError.value = 'Konfirmasi password tidak boleh kosong';
      return false;
    } else if (confirmController.text != passwordController.text) {
      confirmError.value = 'Password tidak cocok';
      return false;
    } else {
      confirmError.value = '';
      return true;
    }
  }

  void prepareOtpVerification(String email) {
    pendingVerificationEmail.value = email.trim();
    otpController.clear();
    otpError.value = '';
  }

  bool validateOtp() {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      otpError.value = 'Kode OTP tidak boleh kosong';
      return false;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      otpError.value = 'Kode OTP harus 6 digit angka';
      return false;
    }
    otpError.value = '';
    return true;
  }

  void _showGoogleAccountChoice({
    required String email,
    required String message,
    bool preferAppPassword = false,
  }) {
    void openAppPassword() {
      Get.back();
      Get.toNamed(AppRoutes.appPassword, arguments: {'email': email});
    }

    void openGoogleLogin() {
      Get.back();
      signInWithGoogle();
    }

    Widget actionTile({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      bool primary = false,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: primary ? AppTheme.primaryGradient : null,
              color: primary ? null : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: primary
                  ? null
                  : Border.all(color: const Color(0xFFE5E7EB), width: 1),
              boxShadow: primary ? AppTheme.buttonShadow : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primary
                        ? Colors.white.withValues(alpha: 0.18)
                        : AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: primary ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: primary ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: primary
                              ? Colors.white.withValues(alpha: 0.84)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: primary ? Colors.white : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      );
    }

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_circle_rounded,
                    color: AppColors.primary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Akun Google Terdeteksi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 22),
                if (preferAppPassword) ...[
                  actionTile(
                    icon: Icons.key_rounded,
                    title: 'Buat Password Aplikasi',
                    subtitle:
                        'Verifikasi OTP lalu buat password khusus SEHATI.',
                    onTap: openAppPassword,
                    primary: true,
                  ),
                  const SizedBox(height: 12),
                  actionTile(
                    icon: Icons.g_mobiledata_rounded,
                    title: 'Masuk dengan Google',
                    subtitle: 'Gunakan metode login Google seperti biasa.',
                    onTap: openGoogleLogin,
                  ),
                ] else ...[
                  actionTile(
                    icon: Icons.g_mobiledata_rounded,
                    title: 'Masuk dengan Google',
                    subtitle: 'Metode tercepat untuk akun ini.',
                    onTap: openGoogleLogin,
                    primary: true,
                  ),
                  const SizedBox(height: 12),
                  actionTile(
                    icon: Icons.key_rounded,
                    title: 'Buat Password Aplikasi',
                    subtitle: 'Tambahkan opsi login email dan password.',
                    onTap: openAppPassword,
                  ),
                ],
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Nanti Dulu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (!validateEmail() || !validatePassword()) {
      return;
    }
    isLoading.value = true;
    try {
      final response = await _apiProvider.login(
        emailController.text.trim(),
        passwordController.text,
      );
      final body = _body(response);

      if (response.status.isOk) {
        token.value = body['token']?.toString() ?? '';
        userData.value = body['user'] is Map
            ? Map<String, dynamic>.from(body['user'])
            : <String, dynamic>{};
        isLogin.value = true;

        Get.offAllNamed(AppRoutes.home);
      } else {
        final message = _message(response, fallback: 'Login Gagal');
        if (body['can_create_app_password'] == true) {
          final email = (body['email'] ?? emailController.text.trim())
              .toString();
          _showGoogleAccountChoice(email: email, message: message);
          return;
        }
        if (response.statusCode == 403 &&
            body['action'] == 'reactivate_prompt') {
          final email = (body['email'] ?? emailController.text.trim())
              .toString();
          _showReactivationPrompt(
            email: email,
            provider: body['provider']?.toString() ?? 'email',
            password: passwordController.text,
          );
          return;
        }
        if (response.statusCode == 403 &&
            body['requires_verification'] == true) {
          final email = (body['email'] ?? emailController.text.trim())
              .toString();
          prepareOtpVerification(email);
          Get.toNamed(AppRoutes.verifyOtp, arguments: {'email': email});
          Get.snackbar(
            'Verifikasi Email',
            message,
            backgroundColor: Colors.orange.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        Get.snackbar(
          'Login Gagal',
          message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Login Gagal',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!validateName() ||
        !validateEmail() ||
        !validatePassword() ||
        !validateConfirmPassword()) {
      return;
    }
    if (!agreedToTerms.value) {
      Get.snackbar(
        'Persetujuan Diperlukan',
        'Anda harus menyetujui Syarat & Ketentuan terlebih dahulu.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isLoading.value = true;
    try {
      final response = await _apiProvider.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        null,
      );
      final body = _body(response);

      if (response.status.isOk) {
        final requiresOtp = body['requires_otp'] != false;
        if (!requiresOtp) {
          passwordController.clear();
          confirmController.clear();
          Get.offAllNamed(AppRoutes.login);
          Get.snackbar(
            'Registrasi Berhasil',
            body['message']?.toString() ??
                'Akun berhasil dibuat tanpa verifikasi OTP.',
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final email = (body['email'] ?? emailController.text.trim()).toString();
        prepareOtpVerification(email);
        Get.toNamed(AppRoutes.verifyOtp, arguments: {'email': email});
        Get.snackbar(
          'Kode OTP Terkirim',
          body['message']?.toString() ??
              'Kode OTP telah dikirim ke email Anda.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final message = _message(response, fallback: 'Pendaftaran Gagal');
        if (body['can_create_app_password'] == true) {
          final email = (body['email'] ?? emailController.text.trim())
              .toString();
          _showGoogleAccountChoice(email: email, message: message);
          return;
        }
        Get.snackbar(
          'Pendaftaran Gagal',
          message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Pendaftaran Gagal',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp({String? email}) async {
    final verificationEmail = (email ?? pendingVerificationEmail.value).trim();

    if (verificationEmail.isEmpty) {
      Get.snackbar(
        'Email Tidak Ditemukan',
        'Silakan ulangi proses register.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!validateOtp()) {
      return;
    }

    isVerifyLoading.value = true;
    try {
      final response = await _apiProvider.verifyOtp(
        verificationEmail,
        otpController.text.trim(),
      );
      final body = _body(response);

      if (response.status.isOk) {
        otpController.clear();
        passwordController.clear();
        confirmController.clear();
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar(
          'Verifikasi Berhasil',
          body['message']?.toString() ?? 'Email berhasil diverifikasi.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final message = _message(response, fallback: 'Verifikasi OTP gagal');
        otpError.value = message;
        Get.snackbar(
          'Verifikasi Gagal',
          message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Verifikasi Gagal',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isVerifyLoading.value = false;
    }
  }

  Future<bool> resendOtp({String? email}) async {
    final verificationEmail = (email ?? pendingVerificationEmail.value).trim();

    if (verificationEmail.isEmpty) {
      Get.snackbar(
        'Email Tidak Ditemukan',
        'Silakan ulangi proses register.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isResendLoading.value = true;
    try {
      final response = await _apiProvider.resendOtp(verificationEmail);
      final body = _body(response);

      if (response.status.isOk) {
        otpController.clear();
        otpError.value = '';
        Get.snackbar(
          'Kode OTP Baru',
          body['message']?.toString() ??
              'Kode OTP baru telah dikirim ke email Anda.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }

      final message = _message(response, fallback: 'Gagal mengirim ulang OTP');
      Get.snackbar(
        'Resend Gagal',
        message,
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Resend Gagal',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isResendLoading.value = false;
    }
  }

  Future<bool> requestForgotPasswordOtp(String email) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      Get.snackbar(
        'Email Wajib Diisi',
        'Masukkan email akun Anda terlebih dahulu.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      final response = await _apiProvider.forgotPassword(normalizedEmail);
      final body = _body(response);
      if (response.status.isOk) {
        Get.snackbar(
          'Kode OTP Terkirim',
          body['message']?.toString() ??
              'Kode OTP telah dikirim ke email Anda.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }

      if (body['can_create_app_password'] == true) {
        final email = (body['email'] ?? normalizedEmail).toString();
        _showGoogleAccountChoice(
          email: email,
          message:
              body['message']?.toString() ??
              'Akun ini terhubung dengan Google.',
          preferAppPassword: true,
        );
        return false;
      }

      Get.snackbar(
        'Gagal Mengirim OTP',
        _message(response, fallback: 'OTP reset password gagal dikirim.'),
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Koneksi Bermasalah',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (!RegExp(r'^\d{6}$').hasMatch(otp.trim())) {
      Get.snackbar(
        'OTP Tidak Valid',
        'Kode OTP harus 6 digit angka.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (password.length < 8) {
      Get.snackbar(
        'Password Terlalu Pendek',
        'Password minimal 8 karakter.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (password != passwordConfirmation) {
      Get.snackbar(
        'Password Tidak Cocok',
        'Konfirmasi password harus sama.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      final response = await _apiProvider.resetPassword(
        email.trim(),
        otp.trim(),
        password,
        passwordConfirmation,
      );
      final body = _body(response);
      if (response.status.isOk) {
        Get.snackbar(
          'Password Berhasil Direset',
          body['message']?.toString() ?? 'Silakan login dengan password baru.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }

      Get.snackbar(
        'Reset Password Gagal',
        _message(response, fallback: 'Kode OTP atau password tidak valid.'),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Reset Password Gagal',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> requestAppPasswordOtp(String email) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      Get.snackbar(
        'Email Wajib Diisi',
        'Masukkan email akun Google Anda terlebih dahulu.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      final response = await _apiProvider.requestAppPassword(normalizedEmail);
      final body = _body(response);
      if (response.status.isOk) {
        Get.snackbar(
          'Kode OTP Terkirim',
          body['message']?.toString() ??
              'Kode OTP telah dikirim ke email Anda.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }

      Get.snackbar(
        'Gagal Mengirim OTP',
        _message(response, fallback: 'OTP password aplikasi gagal dikirim.'),
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Koneksi Bermasalah',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<String?> verifyAppPasswordOtp({
    required String email,
    required String otp,
  }) async {
    if (!RegExp(r'^\d{6}$').hasMatch(otp.trim())) {
      Get.snackbar(
        'OTP Tidak Valid',
        'Kode OTP harus 6 digit angka.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    try {
      final response = await _apiProvider.verifyAppPasswordOtp(
        email.trim(),
        otp.trim(),
      );
      final body = _body(response);
      if (response.status.isOk) {
        Get.snackbar(
          'OTP Terverifikasi',
          body['message']?.toString() ?? 'Silakan buat password aplikasi Anda.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return body['setup_token']?.toString();
      }

      Get.snackbar(
        'Verifikasi OTP Gagal',
        _message(response, fallback: 'Kode OTP tidak valid.'),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'Verifikasi OTP Gagal',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<bool> setAppPasswordWithSetupToken({
    required String email,
    required String setupToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (setupToken.trim().isEmpty) {
      Get.snackbar(
        'Verifikasi Belum Selesai',
        'Verifikasi OTP terlebih dahulu sebelum membuat password.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (password.length < 8) {
      Get.snackbar(
        'Password Terlalu Pendek',
        'Password minimal 8 karakter.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (password != passwordConfirmation) {
      Get.snackbar(
        'Password Tidak Cocok',
        'Konfirmasi password harus sama.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      final response = await _apiProvider.setAppPassword(
        email.trim(),
        setupToken.trim(),
        password,
        passwordConfirmation,
      );
      final body = _body(response);
      if (response.status.isOk) {
        if (body['token'] != null && body['user'] is Map) {
          token.value = body['token'].toString();
          userData.value = Map<String, dynamic>.from(body['user']);
          isLogin.value = true;
        }

        Get.snackbar(
          'Password Aplikasi Dibuat',
          body['message']?.toString() ??
              'Sekarang Anda bisa login memakai email dan password aplikasi.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }

      Get.snackbar(
        'Gagal Membuat Password',
        _message(response, fallback: 'Kode OTP atau password tidak valid.'),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Gagal Membuat Password',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> requestEmailChangeOtp({
    required String newEmail,
    required String currentPassword,
  }) async {
    if (token.value.isEmpty) return false;
    try {
      final response = await _apiProvider.requestEmailChange(
        token.value,
        newEmail.trim(),
        currentPassword,
      );
      final body = _body(response);
      if (response.status.isOk) {
        _updateOtpTimingFromBody(body);
        Get.snackbar(
          'OTP Email Baru Terkirim',
          body['message']?.toString() ?? 'Cek email baru Anda.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      Get.snackbar(
        'Gagal Mengirim OTP',
        _message(response, fallback: 'Email tidak bisa diganti.'),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Koneksi Bermasalah',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> confirmEmailChange({
    required String newEmail,
    required String otp,
    bool showSuccessSnackbar = true,
  }) async {
    if (token.value.isEmpty) return false;
    try {
      final response = await _apiProvider.confirmEmailChange(
        token.value,
        newEmail.trim(),
        otp.trim(),
      );
      final body = _body(response);
      if (response.status.isOk) {
        if (body['user'] is Map) {
          userData.value = Map<String, dynamic>.from(body['user']);
        }
        if (showSuccessSnackbar) {
          Get.snackbar(
            'Email Berhasil Diganti',
            body['message']?.toString() ?? 'Email akun Anda sudah diperbarui.',
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return true;
      }
      Get.snackbar(
        'Verifikasi Email Gagal',
        _message(response, fallback: 'Kode OTP tidak valid.'),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Verifikasi Email Gagal',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> requestPasswordChangeOtp({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    if (token.value.isEmpty) return false;
    try {
      final response = await _apiProvider.requestPasswordChange(
        token.value,
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      );
      final body = _body(response);
      if (response.status.isOk) {
        _updateOtpTimingFromBody(body);
        Get.snackbar(
          'OTP Ganti Password Terkirim',
          body['message']?.toString() ?? 'Cek email Anda.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      Get.snackbar(
        'Gagal Mengirim OTP',
        _message(response, fallback: 'Password tidak bisa diganti.'),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Koneksi Bermasalah',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> confirmPasswordChange({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
    required String otp,
    bool showSuccessSnackbar = true,
  }) async {
    if (token.value.isEmpty) return false;
    try {
      final response = await _apiProvider.confirmPasswordChange(
        token.value,
        currentPassword,
        newPassword,
        newPasswordConfirmation,
        otp.trim(),
      );
      final body = _body(response);
      if (response.status.isOk) {
        if (showSuccessSnackbar) {
          Get.snackbar(
            'Password Berhasil Diganti',
            body['message']?.toString() ??
                'Gunakan password baru saat login berikutnya.',
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return true;
      }
      Get.snackbar(
        'Ganti Password Gagal',
        _message(response, fallback: 'Kode OTP atau password tidak valid.'),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Ganti Password Gagal',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> requestDeleteAccountOtp() async {
    if (token.value.isEmpty) return false;
    try {
      final response = await _apiProvider.requestDeleteAccountOtp(token.value);
      final body = _body(response);
      if (response.status.isOk) {
        _updateOtpTimingFromBody(body);
        Get.snackbar(
          'Kode OTP Dikirim',
          body['message']?.toString() ??
              'Cek email Anda untuk mendapatkan kode OTP penghapusan akun.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
      Get.snackbar(
        'Gagal Mengirim OTP',
        _message(response, fallback: 'Gagal mengirim kode verifikasi OTP.'),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Koneksi Bermasalah',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> confirmDeleteAccount({String? password, String? otpCode}) async {
    if (token.value.isEmpty) return false;
    try {
      final response = await _apiProvider.confirmDeleteAccount(
        token: token.value,
        password: password,
        otpCode: otpCode,
      );
      final body = _body(response);
      if (response.status.isOk) {
        // Clean local sessions
        try {
          await GoogleSignIn().signOut();
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
        isLogin.value = false;
        token.value = '';
        userData.value = {};

        Get.offAllNamed(AppRoutes.login);
        Get.snackbar(
          'Akun Dinonaktifkan',
          body['message']?.toString() ??
              'Akun Anda berhasil dinonaktifkan dan akan dihapus permanen dalam 30 hari.',
          backgroundColor: Colors.orange.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 6),
        );
        return true;
      }
      Get.snackbar(
        'Konfirmasi Gagal',
        _message(
          response,
          fallback: 'Gagal menonaktifkan akun Anda. Pastikan data benar.',
        ),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Koneksi Bermasalah',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> reactivateAccount({
    required String email,
    String? password,
    String? googleToken,
  }) async {
    isLoading.value = true;
    try {
      final response = await _apiProvider.reactivateAccount(
        email: email,
        password: password,
        googleToken: googleToken,
      );
      final body = _body(response);
      if (response.status.isOk) {
        if (body['token'] != null && body['user'] is Map) {
          token.value = body['token'].toString();
          userData.value = Map<String, dynamic>.from(body['user']);
          isLogin.value = true;
        }

        Get.snackbar(
          'Akun Diaktifkan Kembali',
          body['message']?.toString() ??
              'Selamat! Akun Anda telah berhasil dipulihkan.',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        if (isLogin.value) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
        return true;
      }
      Get.snackbar(
        'Aktivasi Gagal',
        _message(response, fallback: 'Gagal mengaktifkan kembali akun Anda.'),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Koneksi Bermasalah',
        _connectionMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _showReactivationPrompt({
    required String email,
    required String provider,
    String? password,
    String? googleToken,
  }) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.restore_from_trash_rounded,
                    color: Colors.orange.shade700,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Aktifkan Kembali Akun?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Akun Anda saat ini dijadwalkan untuk dihapus secara permanen. Ingin membatalkan penghapusan dan mengaktifkannya kembali sekarang?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    Get.back(); // Close prompt dialog
                    await reactivateAccount(
                      email: email,
                      password: password,
                      googleToken: googleToken,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ya, Aktifkan Kembali',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // State lokal tetap dibersihkan walaupun sesi Google sudah tidak aktif.
    }
    isLogin.value = false;
    token.value = '';
    userData.value = {};
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;
    try {
      // PENTING: Gunakan Web Client ID untuk Flutter Web
      // Diambil dari google-services.json (client_type 3)
      const String webClientId =
          '691571373089-t2r3oajabh78af9r1veh4oc5hhb4ebjg.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? webClientId : null,
        serverClientId: kIsWeb ? null : webClientId,
        scopes: ['email', 'profile', 'openid'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      String? idToken = googleAuth.idToken;
      UserCredential? userCredential;

      // Jika idToken null (sering terjadi di Web), coba fallback ke Firebase Auth Popup
      if (kIsWeb && idToken == null) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.addScope('openid');

        userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
        final OAuthCredential? credential =
            userCredential.credential as OAuthCredential?;
        idToken = credential?.idToken ?? await userCredential.user?.getIdToken();
      }

      if (idToken == null) {
        String platformInfo = kIsWeb
            ? 'Pastikan "Authorized JavaScript Origins" di Google Cloud Console sudah mencantumkan URL localhost/domain Anda.'
            : 'Pastikan SHA-1 dan SHA-256 sudah terdaftar di Firebase Console.';

        Get.snackbar(
          'Login Google Gagal',
          'Token Google tidak diterima. $platformInfo',
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 7),
        );
        return;
      }

      // Jika belum login ke Firebase (karena tidak lewat popup fallback)
      if (userCredential == null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: idToken,
        );
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final response = await _apiProvider.loginWithGoogle(
        idToken,
        googleUser.email,
        googleUser.displayName ?? 'Google User',
        userCredential.user?.uid,
      );
      final body = _body(response);

      if (response.status.isOk) {
        token.value = body['token']?.toString() ?? '';
        userData.value = body['user'] is Map
            ? Map<String, dynamic>.from(body['user'])
            : <String, dynamic>{};
        isLogin.value = true;

        Get.offAllNamed(AppRoutes.home);
      } else {
        if (response.statusCode == 403 &&
            body['action'] == 'reactivate_prompt') {
          final email = (body['email'] ?? googleUser.email).toString();
          _showReactivationPrompt(
            email: email,
            provider: 'google',
            googleToken: idToken,
          );
          return;
        }
        final message = _message(response, fallback: 'Login Google gagal.');
        Get.snackbar(
          'Login Gagal',
          message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Login Google Gagal',
        _googleErrorMessage(e),
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }
}
