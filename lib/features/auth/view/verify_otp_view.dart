import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';

class VerifyOtpView extends StatefulWidget {
  const VerifyOtpView({super.key});

  @override
  State<VerifyOtpView> createState() => _VerifyOtpViewState();
}

class _VerifyOtpViewState extends State<VerifyOtpView>
    with TickerProviderStateMixin {
  final auth = Get.find<AuthController>();

  static const int _otpDurationSeconds = 180;   // 3 menit, sesuai OTP_EXPIRES_SECONDS
  static const int _resendCooldownSeconds = 180; // aktif bersamaan saat OTP expired

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnim;

  Timer? _timer;
  int _otpSeconds = _otpDurationSeconds;
  int _resendSeconds = _resendCooldownSeconds;
  String _email = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final args = Get.arguments;
    if (args is Map && args['email'] != null) {
      _email = args['email'].toString();
    } else {
      _email = auth.pendingVerificationEmail.value;
    }
    if (_email.isNotEmpty) {
      auth.prepareOtpVerification(_email);
    }

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    Future.delayed(const Duration(milliseconds: 100), _slideController.forward);
    _startCountdowns();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  void _startCountdowns() {
    _timer?.cancel();
    setState(() {
      _otpSeconds = _otpDurationSeconds;
      _resendSeconds = _resendCooldownSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_otpSeconds == 0 && _resendSeconds == 0) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_otpSeconds > 0) _otpSeconds--;
        if (_resendSeconds > 0) _resendSeconds--;
      });
    });
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleVerify() async {
    await auth.verifyOtp(email: _email);
  }

  Future<void> _handleResend() async {
    if (_resendSeconds > 0 || auth.isResendLoading.value) return;

    final success = await auth.resendOtp(email: _email);
    if (success && mounted) {
      _startCountdowns();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _otpSeconds == 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
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
                  left: -48,
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
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                        'Verifikasi Email',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLighter,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.mark_email_read_rounded,
                                color: AppColors.primary,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Verifikasi Email',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Masukkan kode OTP yang telah dikirim ke email Anda',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (_email.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _email,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 28),
                            Obx(
                              () => TextFormField(
                                controller: auth.otpController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                textAlign: TextAlign.center,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                onFieldSubmitted: (_) => _handleVerify(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 8,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: '000000',
                                  counterText: '',
                                  prefixIcon: const Icon(
                                    Icons.password_rounded,
                                    size: 20,
                                  ),
                                  errorText: auth.otpError.value.isEmpty
                                      ? null
                                      : auth.otpError.value,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? AppColors.secondaryLight
                                    : AppColors.primaryLighter,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isExpired
                                        ? Icons.error_outline_rounded
                                        : Icons.timer_outlined,
                                    color: isExpired
                                        ? AppColors.error
                                        : AppColors.primary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      isExpired
                                          ? 'Kode OTP sudah expired. Silakan kirim ulang kode.'
                                          : 'Kode berlaku ${_formatSeconds(_otpSeconds)}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        height: 1.4,
                                        fontWeight: FontWeight.w700,
                                        color: isExpired
                                            ? AppColors.error
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 26),
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: auth.isVerifyLoading.value
                                        ? null
                                        : AppTheme.primaryGradient,
                                    color: auth.isVerifyLoading.value
                                        ? AppColors.surfaceVariant
                                        : null,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: auth.isVerifyLoading.value
                                        ? null
                                        : AppTheme.buttonShadow,
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: auth.isVerifyLoading.value
                                        ? null
                                        : _handleVerify,
                                    icon: auth.isVerifyLoading.value
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.3,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.verified_rounded,
                                            color: Colors.white,
                                          ),
                                    label: Text(
                                      auth.isVerifyLoading.value
                                          ? 'Memverifikasi'
                                          : 'Verifikasi',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.white,
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
                              ),
                            ),
                            const SizedBox(height: 14),
                            Obx(() {
                              final canResend =
                                  _resendSeconds == 0 &&
                                  !auth.isResendLoading.value;
                              return SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: OutlinedButton.icon(
                                  onPressed: canResend ? _handleResend : null,
                                  icon: auth.isResendLoading.value
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.refresh_rounded,
                                          size: 20,
                                        ),
                                  label: Text(
                                    _resendSeconds > 0
                                        ? 'Resend Code (${_resendSeconds}s)'
                                        : 'Resend Code',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () => Get.offAllNamed(AppRoutes.login),
                              icon: const Icon(Icons.login_rounded, size: 18),
                              label: Text(
                                'Kembali ke Login',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
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
}
