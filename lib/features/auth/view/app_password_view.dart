import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';

class AppPasswordView extends StatefulWidget {
  const AppPasswordView({super.key});

  @override
  State<AppPasswordView> createState() => _AppPasswordViewState();
}

class _AppPasswordViewState extends State<AppPasswordView> {
  final auth = Get.find<AuthController>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Timer? _timer;
  bool _otpSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _otpSeconds = 180;
  bool _otpExpired = false;
  String _setupToken = '';

  bool get _isOtpStep => _otpSent && _setupToken.isEmpty;
  bool get _isPasswordStep => _setupToken.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['email'] != null) {
      _emailController.text = args['email'].toString();
      // Email sudah diketahui dari flow sebelumnya → langsung ke OTP step
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _proceedToOtpStep();
      });
    } else {
      _emailController.text = auth.emailController.text.trim();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _otpSeconds = 180;
      _otpExpired = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_otpSeconds > 0) {
          _otpSeconds--;
        } else {
          _otpExpired = true;
          t.cancel();
        }
      });
    });
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _proceedToOtpStep() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        'Email Tidak Valid',
        'Masukkan email akun Google yang benar.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() {
      _otpSent = true;
      _setupToken = '';
      _otpController.clear();
      _passwordController.clear();
      _confirmController.clear();
    });
    await _sendOtp();
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    final success = await auth.requestAppPasswordOtp(_emailController.text.trim());
    if (success && mounted) {
      _startCountdown();
    } else if (!success && mounted) {
      setState(() {
        _otpSent = false;
        _setupToken = '';
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    final setupToken = await auth.verifyAppPasswordOtp(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
    );
    if (setupToken != null && mounted) {
      _timer?.cancel();
      setState(() {
        _setupToken = setupToken;
        _passwordController.clear();
        _confirmController.clear();
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _setPassword() async {
    setState(() => _isLoading = true);
    final wasLoggedIn = auth.isLogin.value;
    final success = await auth.setAppPasswordWithSetupToken(
      email: _emailController.text.trim(),
      setupToken: _setupToken,
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
    );
    if (success) {
      auth.emailController.text = _emailController.text.trim();
      auth.passwordController.clear();
      if (wasLoggedIn) {
        auth.userData['has_password'] = true;
        Get.back();
      } else if (auth.isLogin.value) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _backToEmailStep() {
    _timer?.cancel();
    setState(() {
      _otpSent = false;
      _setupToken = '';
      _otpExpired = false;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _isOtpStep && _otpExpired;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildHeaderBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHero(),
                          const SizedBox(height: 24),
                          _buildStepIndicator(),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeOutCubic,
                            child: _isPasswordStep
                                ? _buildPasswordStep()
                                : _isOtpStep
                                ? _buildOtpStep(isExpired)
                                : _buildEmailStep(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      height: 250,
      decoration: BoxDecoration(gradient: AppTheme.heroGradient),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            left: -46,
            bottom: 28,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Password Aplikasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(
            _isPasswordStep
                ? Icons.lock_rounded
                : _isOtpStep
                ? Icons.mark_email_read_rounded
                : Icons.key_rounded,
            color: AppColors.primary,
            size: 38,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _isPasswordStep
              ? 'Buat Password Aplikasi'
              : _isOtpStep
              ? 'Verifikasi OTP'
              : 'Tautkan Password Aplikasi',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isPasswordStep
              ? 'OTP sudah valid. Sekarang buat password khusus SmartFarmasi.'
              : _isOtpStep
              ? 'Masukkan kode 6 digit yang kami kirim ke email Google Anda.'
              : 'Password ini hanya untuk SmartFarmasi. Password Gmail asli tidak pernah diminta.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    final activeStep = _isPasswordStep
        ? 3
        : _isOtpStep
        ? 2
        : 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          _buildStepPill(1, 'Email', activeStep >= 1, activeStep == 1),
          _buildStepLine(activeStep >= 2),
          _buildStepPill(2, 'OTP', activeStep >= 2, activeStep == 2),
          _buildStepLine(activeStep >= 3),
          _buildStepPill(3, 'Password', activeStep >= 3, activeStep == 3),
        ],
      ),
    );
  }

  Widget _buildStepPill(int number, String label, bool isDone, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDone ? AppColors.primary : const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone && !isActive
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : Text(
                      '$number',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDone ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Container(
      width: 22,
      height: 2,
      margin: const EdgeInsets.only(bottom: 22),
      color: isDone ? AppColors.primary : const Color(0xFFE5E7EB),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey('email-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBox(
          icon: Icons.verified_user_outlined,
          title: 'Satu Email, Satu Akun',
          body:
              'Kami akan memastikan email Google ini benar milik Anda sebelum password aplikasi dibuat.',
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Google',
            hintText: 'contoh@gmail.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          label: 'Lanjut',
          icon: Icons.arrow_forward_rounded,
          onPressed: _proceedToOtpStep,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => Get.offAllNamed(AppRoutes.login),
          icon: const Icon(Icons.login_rounded, size: 18),
          label: const Text('Kembali ke Login'),
        ),
      ],
    );
  }

  Widget _buildOtpStep(bool isExpired) {
    return Column(
      key: const ValueKey('otp-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEmailSummary(),
        const SizedBox(height: 16),
        if (_isLoading) ...[
          const SizedBox(height: 24),
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mengirim kode OTP ke email Anda...',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
        ] else ...[
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            enabled: !isExpired,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 10,
              color: isExpired ? AppColors.textTertiary : AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              counterText: '',
              labelText: 'Kode OTP',
              hintText: '000000',
              prefixIcon: Icon(Icons.password_rounded),
            ),
            onFieldSubmitted: (_) => isExpired ? null : _verifyOtp(),
          ),
          const SizedBox(height: 16),
          _buildTimerBox(isExpired),
          const SizedBox(height: 24),
          if (!isExpired)
            _buildPrimaryButton(
              label: 'Verifikasi OTP',
              icon: Icons.verified_rounded,
              onPressed: _verifyOtp,
            )
          else
            OutlinedButton.icon(
              onPressed: _backToEmailStep,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Kembali & Kirim Ulang OTP'),
            ),
        ],
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      key: const ValueKey('password-step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEmailSummary(verified: true),
        const SizedBox(height: 18),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password Aplikasi',
            hintText: 'Minimal 8 karakter',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            labelText: 'Konfirmasi Password',
            hintText: 'Ulangi password aplikasi',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
          onFieldSubmitted: (_) => _setPassword(),
        ),
        const SizedBox(height: 18),
        _buildInfoBox(
          icon: Icons.info_outline_rounded,
          title: 'Password Khusus SmartFarmasi',
          body:
              'Password ini tidak mengubah password Google Anda. Anda tetap bisa login dengan Google kapan saja.',
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          label: 'Simpan & Masuk',
          icon: Icons.verified_user_rounded,
          onPressed: _setPassword,
        ),
      ],
    );
  }

  Widget _buildEmailSummary({bool verified = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: verified ? AppColors.primaryLighter : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: verified
              ? AppColors.primary.withValues(alpha: 0.18)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              verified ? Icons.mark_email_read_rounded : Icons.email_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verified ? 'Email terverifikasi' : 'OTP dikirim ke',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _emailController.text.trim(),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBox(bool isExpired) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isExpired ? AppColors.secondaryLight : AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isExpired ? Icons.timer_off_rounded : Icons.timer_outlined,
            color: isExpired ? AppColors.error : AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isExpired
                  ? 'Kode OTP kedaluwarsa. Kembali untuk kirim ulang.'
                  : 'Kode berlaku selama ${_formatSeconds(_otpSeconds)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isExpired ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppTheme.primaryGradient,
          color: _isLoading ? AppColors.surfaceVariant : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading ? null : AppTheme.buttonShadow,
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : onPressed,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: AppColors.primary,
                  ),
                )
              : Icon(icon, color: Colors.white),
          label: Text(
            _isLoading ? 'Memproses' : label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
