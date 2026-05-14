import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  final auth = Get.find<AuthController>();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 100), _slideController.forward);
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    auth.register();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Header
          Container(
            height: 200,
            decoration: BoxDecoration(gradient: AppTheme.heroGradient),
            child: Stack(
              children: [
                Positioned(
                  top: -40,
                  right: -40,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar area
                Padding(
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
                        'Buat Akun Baru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Form Card
                Expanded(
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: Container(
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
                              'Data Diri Anda',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Lengkapi informasi di bawah untuk membuat akun',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Name
                             _buildLabel('Nama Lengkap'),
                             const SizedBox(height: 8),
                             TextFormField(
                               controller: auth.nameController,
                               textInputAction: TextInputAction.next,
                               textCapitalization: TextCapitalization.words,
                               style: _inputStyle(),
                               decoration: InputDecoration(
                                 hintText: 'Nama lengkap Anda',
                                 prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                                 errorText: auth.nameError.value.isEmpty ? null : auth.nameError.value,
                               ),
                             ),

                            const SizedBox(height: 20),

                            // Email
                             _buildLabel('Email'),
                             const SizedBox(height: 8),
                             TextFormField(
                               controller: auth.emailController,
                               keyboardType: TextInputType.emailAddress,
                               textInputAction: TextInputAction.next,
                               style: _inputStyle(),
                               decoration: InputDecoration(
                                 hintText: 'contoh@email.com',
                                 prefixIcon: const Icon(Icons.email_outlined, size: 20),
                                 errorText: auth.emailError.value.isEmpty ? null : auth.emailError.value,
                               ),
                             ),

                            const SizedBox(height: 20),

                            // Password
                             _buildLabel('Password'),
                             const SizedBox(height: 8),
                             Obx(() => TextFormField(
                               controller: auth.passwordController,
                               obscureText: auth.obscurePassword.value,
                               textInputAction: TextInputAction.next,
                               style: _inputStyle(),
                               decoration: InputDecoration(
                                 hintText: 'Min. 8 karakter',
                                 prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                 suffixIcon: GestureDetector(
                                   onTap: auth.togglePasswordVisibility,
                                   child: Icon(
                                     auth.obscurePassword.value
                                         ? Icons.visibility_off_outlined
                                         : Icons.visibility_outlined,
                                     size: 20,
                                   ),
                                 ),
                                 errorText: auth.passwordError.value.isEmpty ? null : auth.passwordError.value,
                               ),
                             )),

                            const SizedBox(height: 20),

                            // Confirm Password
                             _buildLabel('Konfirmasi Password'),
                             const SizedBox(height: 8),
                             Obx(() => TextFormField(
                               controller: auth.confirmController,
                               obscureText: auth.obscureConfirm.value,
                               textInputAction: TextInputAction.done,
                               style: _inputStyle(),
                               onFieldSubmitted: (_) => _handleRegister(),
                               decoration: InputDecoration(
                                 hintText: 'Ulangi password',
                                 prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                 suffixIcon: GestureDetector(
                                   onTap: auth.toggleConfirmVisibility,
                                   child: Icon(
                                     auth.obscureConfirm.value
                                         ? Icons.visibility_off_outlined
                                         : Icons.visibility_outlined,
                                     size: 20,
                                   ),
                                 ),
                                 errorText: auth.confirmError.value.isEmpty ? null : auth.confirmError.value,
                               ),
                             )),

                            const SizedBox(height: 24),

                            // Terms & Conditions
                            GestureDetector(
                              onTap: auth.toggleTermsAgreement,
                              child: Row(
                                children: [
                                  Obx(() => AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: auth.agreedToTerms.value
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: auth.agreedToTerms.value
                                            ? AppColors.primary
                                            : AppColors.textTertiary,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: auth.agreedToTerms.value
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          )
                                        : null,
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                        children: [
                                          const TextSpan(text: 'Saya setuju dengan '),
                                          TextSpan(
                                            text: 'Syarat & Ketentuan',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const TextSpan(text: ' dan '),
                                          TextSpan(
                                            text: 'Kebijakan Privasi',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Register Button
                            Obx(() => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: auth.isLoading.value ? null : AppTheme.primaryGradient,
                                color: auth.isLoading.value ? AppColors.surfaceVariant : null,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: auth.isLoading.value ? null : AppTheme.buttonShadow,
                              ),
                              child: ElevatedButton(
                                onPressed: auth.isLoading.value ? null : _handleRegister,
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
                                        'Buat Akun',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            )),

                             const SizedBox(height: 24),
                             
                             // Divider
                             Row(
                               children: [
                                 const Expanded(child: Divider()),
                                 Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 12),
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

                             // Already have account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sudah punya akun? ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.back(),
                                  child: Text(
                                    'Masuk di sini',
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
                ),
              ],
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
          colors: [
            Colors.white,
            Color(0xFFFAFAFA),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.5,
        ),
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
                    'Daftar dengan Google',
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

  TextStyle _inputStyle() => GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      );
}
