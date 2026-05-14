import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../controller/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final auth = Get.find<AuthController>();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    auth.login();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient header section
          Container(
            height: size.height * 0.42,
            decoration: BoxDecoration(gradient: AppTheme.heroGradient),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: -40,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Logo & Title in the gradient area
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_pharmacy_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'SmartFarmasi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kesehatan cerdas di genggaman Anda',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Form Card - slides up
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Masuk ke akun Anda untuk melanjutkan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Email
                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: auth.emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'contoh@email.com',
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                ),
                                errorText: auth.emailError.value.isEmpty
                                    ? null
                                    : auth.emailError.value,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLabel('Password'),
                                TextButton(
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Lupa password?',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => TextFormField(
                                controller: auth.passwordController,
                                obscureText: auth.obscurePassword.value,
                                textInputAction: TextInputAction.done,
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                onFieldSubmitted: (_) => _handleLogin(),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 20,
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: auth.togglePasswordVisibility,
                                    child: Icon(
                                      auth.obscurePassword.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                    ),
                                  ),
                                  errorText: auth.passwordError.value.isEmpty
                                      ? null
                                      : auth.passwordError.value,
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Login Button
                            Obx(
                              () => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: auth.isLoading.value
                                      ? null
                                      : AppTheme.primaryGradient,
                                  color: auth.isLoading.value
                                      ? AppColors.surfaceVariant
                                      : null,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: auth.isLoading.value
                                      ? null
                                      : AppTheme.buttonShadow,
                                ),
                                child: ElevatedButton(
                                  onPressed: auth.isLoading.value
                                      ? null
                                      : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: auth.isLoading.value
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : Text(
                                          'Masuk',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'atau',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Google Login Button
                            Obx(() => _buildGoogleButton()),

                            const SizedBox(height: 24),

                            // Register Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Belum punya akun? ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(AppRoutes.register),
                                  child: Text(
                                    'Daftar sekarang',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: auth.isGoogleLoading.value ? null : auth.signInWithGoogle,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF4285F4).withValues(alpha: 0.08),
          highlightColor: const Color(0xFF4285F4).withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (auth.isGoogleLoading.value)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4285F4),
                      ),
                    ),
                  )
                else ...[
                  // Google Logo from IconScout
                  Image.network(
                    'https://cdn.iconscout.com/icon/free/png-512/free-google-logo-icon-download-in-svg-png-gif-file-formats--technology-social-media-company-brand-vol-1-pack-logos-icons-189813.png',
                    height: 24,
                    width: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 32,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text dengan typography premium
                  Text(
                    'Lanjutkan dengan Google',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.2,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
