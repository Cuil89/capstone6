// test/mocks/mock_auth_controller.dart
//
// MockAuthController – subclass AuthController yang aman untuk testing.
// Meng-override semua method yang memanggil API/Firebase dengan no-op atau
// simulasi sederhana, sehingga tidak membutuhkan Firebase ataupun backend.
//
// PENGGUNAAN:
//   final mock = MockAuthController();
//   Get.put<AuthController>(mock);   // ← works karena mock IS-A AuthController

import 'package:smart_farmasi1/features/auth/controller/auth_controller.dart';

class MockAuthController extends AuthController {
  // ── onInit: jangan panggil super agar tidak menyentuh Firebase/API ────────
  @override
  void onInit() {
    // Sengaja kosong – tidak memanggil super.onInit()
  }

  @override
  void onClose() {
    // Override tanpa super untuk testing
    onInit();
  }

  // ── Data dummy helpers ────────────────────────────────────────────────────

  /// Set state sebagai user yang sudah login.
  void setLoggedInUser() {
    isLogin.value = true;
    token.value = 'fake_token_for_testing';
    userData.value = {
      'name': 'Test User',
      'email': 'testuser@example.com',
      'provider': 'email',
      'has_password': true,
      'is_verified': true,
      'profile_picture_url': '',
    };
  }

  /// Set state sebagai guest (belum login).
  void setGuestUser() {
    isLogin.value = false;
    token.value = '';
    userData.value = {'name': 'Guest', 'email': ''};
  }

  // ── Override semua method yang memanggil API / Firebase ──────────────────

  @override
  Future<void> login() async {
    emailError.value = '';
    passwordError.value = '';

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      emailError.value = 'Email tidak boleh kosong';
      return;
    }
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email)) {
      emailError.value = 'Format email tidak valid';
      return;
    }
    if (password.isEmpty) {
      passwordError.value = 'Password tidak boleh kosong';
      return;
    }
    if (password.length < 8) {
      passwordError.value = 'Password minimal 8 karakter';
      return;
    }

    // Simulasi sukses hanya untuk credential dummy
    if (email == 'testuser@example.com' && password == 'password123') {
      setLoggedInUser();
    }
  }

  @override
  Future<void> register() async {
    nameError.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmError.value = '';

    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Nama tidak boleh kosong';
      return;
    }
    if (emailController.text.trim().isEmpty) {
      emailError.value = 'Email tidak boleh kosong';
      return;
    }
    if (!RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(emailController.text.trim())) {
      emailError.value = 'Format email tidak valid';
      return;
    }
    if (passwordController.text.isEmpty) {
      passwordError.value = 'Password tidak boleh kosong';
      return;
    }
    if (passwordController.text.length < 8) {
      passwordError.value = 'Password minimal 8 karakter';
      return;
    }
    if (confirmController.text != passwordController.text) {
      confirmError.value = 'Password tidak cocok';
      return;
    }
  }

  @override
  Future<void> logout() async {
    isLogin.value = false;
    token.value = '';
    userData.value = {};
  }

  @override
  Future<void> signInWithGoogle() async {
    // No-op dalam test
  }

  @override
  Future<void> verifyOtp({String? email}) async {}

  @override
  Future<bool> resendOtp({String? email}) async => true;

  @override
  Future<bool> requestForgotPasswordOtp(String email) async => true;

  @override
  Future<bool> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async => true;

  @override
  Future<bool> requestAppPasswordOtp(String email) async => true;

  @override
  Future<String?> verifyAppPasswordOtp({
    required String email,
    required String otp,
  }) async => 'mock_setup_token';

  @override
  Future<bool> setAppPasswordWithSetupToken({
    required String email,
    required String setupToken,
    required String password,
    required String passwordConfirmation,
  }) async => true;

  // changeEmail tidak ada di AuthController – hapus
  // changePassword tidak ada di AuthController – hapus
  // deactivateAccount tidak ada di AuthController – hapus
}
