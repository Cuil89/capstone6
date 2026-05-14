import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView>
    with TickerProviderStateMixin {
  final auth = Get.find<AuthController>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // 6 OTP box controllers
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  // Step: 0 = email, 1 = otp, 2 = new password
  int _step = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _email = '';

  // OTP countdown — no resend, only countdown
  Timer? _timer;
  int _otpSeconds = 60;
  bool _otpExpired = false;

  late final AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _emailController.text = auth.emailController.text.trim();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _resetSlide();
    Future.delayed(
      const Duration(milliseconds: 80),
      _slideController.forward,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _resetSlide({bool fromRight = true}) {
    _slideAnim = Tween<Offset>(
      begin: Offset(fromRight ? 0.25 : -0.25, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _animateToStep(int newStep, {bool forward = true}) async {
    _slideController.reset();
    _resetSlide(fromRight: forward);
    setState(() => _step = newStep);
    _slideController.forward();
  }

  // ── Step 0: Lanjut ke OTP step (hanya validasi email) ──────────
  Future<void> _proceedToOtpStep() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      _showError('Masukkan alamat email yang valid.');
      return;
    }
    _email = email;
    await _animateToStep(1);
    _sendOtp();
  }

  // ── Step 1: Kirim OTP (otomatis dipanggil saat masuk step 1) ────
  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    final ok = await auth.requestForgotPasswordOtp(_email);
    if (mounted) setState(() => _isLoading = false);
    if (ok && mounted) {
      _startCountdown();
    } else if (!ok && mounted) {
      await _animateToStep(0, forward: false);
    }
  }

  // ── OTP countdown (tidak ada resend) ──────────────────────────
  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _otpSeconds = 180; // 3 menit, sesuai backend OTP_EXPIRES_SECONDS
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

  String _fmtSeconds(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ── Step 2: Verifikasi OTP ─────────────────────────────────────
  String get _otpValue =>
      _otpControllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final otp = _otpValue;
    if (otp.length < 6) {
      _showError('Masukkan 6 digit kode OTP.');
      return;
    }
    if (_otpExpired) {
      _showError('Kode OTP sudah kedaluwarsa. Coba lagi dari awal.');
      return;
    }
    // Langsung lanjut ke step 3 — verifikasi final dilakukan saat reset
    await _animateToStep(2);
  }

  // ── Step 3: Reset password ─────────────────────────────────────
  Future<void> _resetPassword() async {
    final pw = _passwordController.text;
    final cf = _confirmController.text;
    if (pw.length < 8) {
      _showError('Password minimal 8 karakter.');
      return;
    }
    if (pw != cf) {
      _showError('Konfirmasi password tidak cocok.');
      return;
    }
    setState(() => _isLoading = true);
    final ok = await auth.resetPasswordWithOtp(
      email: _email,
      otp: _otpValue,
      password: pw,
      passwordConfirmation: cf,
    );
    if (mounted) setState(() => _isLoading = false);
    if (ok) {
      auth.emailController.text = _email;
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      'Perhatian',
      msg,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }

  // ── Back per step ──────────────────────────────────────────────
  void _handleBack() {
    if (_step == 0) {
      Get.back();
    } else if (_step == 1) {
      _timer?.cancel();
      _animateToStep(0, forward: false);
    } else {
      _animateToStep(1, forward: false);
    }
  }

  // ── OTP box input handler ──────────────────────────────────────
  void _onOtpChanged(String val, int idx) {
    if (val.isNotEmpty && idx < 5) {
      _otpFocusNodes[idx + 1].requestFocus();
    }
    if (val.isEmpty && idx > 0) {
      _otpFocusNodes[idx - 1].requestFocus();
    }
    setState(() {});
  }

  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Hero gradient header
          Container(
            height: 220,
            decoration: BoxDecoration(gradient: AppTheme.heroGradient),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  left: -50,
                  bottom: 20,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── App bar ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _handleBack,
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
                      const SizedBox(width: 6),
                      Text(
                        'Lupa Password',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Step indicator ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: _StepIndicator(currentStep: _step),
                ),

                // ── Content card ─────────────────────────────────
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: _buildStepContent(),
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

  Widget _buildStepContent() {
    return switch (_step) {
      0 => _buildEmailStep(),
      1 => _buildOtpStep(),
      _ => _buildPasswordStep(),
    };
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 0 — Email
  // ─────────────────────────────────────────────────────────────
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepIcon(icon: Icons.mail_lock_rounded, color: AppColors.primary),
        const SizedBox(height: 22),
        Text(
          'Masukkan Email Anda',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kami akan mengirimkan kode OTP 6 digit ke email terdaftar Anda.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _sendOtp(),
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'contoh@email.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          label: 'Lanjut',
          icon: Icons.arrow_forward_rounded,
          isLoading: false,
          onTap: _proceedToOtpStep,
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => Get.offAllNamed(AppRoutes.login),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Kembali ke Login'),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 1 — OTP
  // ─────────────────────────────────────────────────────────────
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepIcon(
          icon: Icons.mark_email_read_rounded,
          color: AppColors.primary,
        ),
        const SizedBox(height: 22),
        Text(
          'Cek Email Anda',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kode OTP dikirim ke',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _email,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 28),

        // ── Loading saat OTP sedang dikirim ──
        if (_isLoading) ...[
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mengirim kode OTP ke email Anda...',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
        ] else ...[
          // 6-box OTP input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _OtpBox(
              controller: _otpControllers[i],
              focusNode: _otpFocusNodes[i],
              onChanged: (v) => _onOtpChanged(v, i),
              isExpired: _otpExpired,
            )),
          ),

          const SizedBox(height: 20),

          // Timer / expired banner
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: _otpExpired
                  ? AppColors.secondaryLight
                  : AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  _otpExpired
                      ? Icons.timer_off_rounded
                      : Icons.timer_outlined,
                  size: 20,
                  color: _otpExpired ? AppColors.error : AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _otpExpired
                        ? 'Kode OTP kedaluwarsa. Kembali & coba lagi.'
                        : 'Kode berlaku selama ${_fmtSeconds(_otpSeconds)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _otpExpired ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _PrimaryButton(
            label: 'Verifikasi Kode',
            icon: Icons.verified_rounded,
            isLoading: false,
            onTap: _otpExpired ? null : _verifyOtp,
          ),

          if (_otpExpired) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                _timer?.cancel();
                _animateToStep(0, forward: false);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Kembali & Kirim Ulang'),
            ),
          ],
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Get.offAllNamed(AppRoutes.login),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Kembali ke Login'),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 2 — New password
  // ─────────────────────────────────────────────────────────────
  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepIcon(icon: Icons.lock_reset_rounded, color: AppColors.primary),
        const SizedBox(height: 22),
        Text(
          'Buat Password Baru',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Buat password yang kuat dan mudah diingat. Minimal 8 karakter.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Password Baru',
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
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _resetPassword(),
          decoration: InputDecoration(
            labelText: 'Konfirmasi Password',
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
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          label: 'Reset Password',
          icon: Icons.check_circle_rounded,
          isLoading: _isLoading,
          onTap: _resetPassword,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => Get.offAllNamed(AppRoutes.login),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Kembali ke Login'),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _labels = ['Email', 'Kode OTP', 'Password Baru'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDone || isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _labels[i],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (i < 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _StepIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.primaryLighter,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(icon, color: color, size: 38),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: (isLoading || onTap == null) ? null : AppTheme.primaryGradient,
          color: (isLoading || onTap == null)
              ? AppColors.surfaceVariant
              : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: (isLoading || onTap == null)
              ? null
              : AppTheme.buttonShadow,
        ),
        child: ElevatedButton.icon(
          onPressed: (isLoading || onTap == null) ? null : onTap,
          icon: isLoading
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
            isLoading ? 'Memproses...' : label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isLoading ? AppColors.textSecondary : Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool isExpired;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    return SizedBox(
      width: 44,
      height: 54,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onChanged('');
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isExpired ? AppColors.error : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: isExpired
                ? AppColors.secondaryLight
                : filled
                    ? AppColors.primaryLighter
                    : AppColors.surfaceVariant,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isExpired
                    ? AppColors.error.withValues(alpha: 0.4)
                    : filled
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : const Color(0xFFE5E7EB),
                width: filled ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isExpired ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
