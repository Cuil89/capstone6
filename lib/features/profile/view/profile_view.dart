import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _listSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _listSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _listController, curve: Curves.easeOutCubic),
        );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), _listController.forward);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── PROFILE HEADER ───
            FadeTransition(
              opacity: _headerOpacity,
              child: _buildProfileHeader(),
            ),

            // ─── BODY ───
            SlideTransition(
              position: _listSlide,
              child: FadeTransition(
                opacity: _headerOpacity,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Row
                      _buildStatsRow(),

                      const SizedBox(height: 28),

                      // Account Settings
                      _buildSectionTitle('Akun Saya'),
                      const SizedBox(height: 12),
                      _buildMenuCard([
                        _MenuItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Data Pribadi',
                          subtitle: 'Nama, tanggal lahir, jenis kelamin',
                          color: AppColors.primary,
                          bgColor: AppColors.primaryLighter,
                        ),
                        _MenuItem(
                          icon: Icons.history_rounded,
                          label: 'Riwayat Kesehatan',
                          subtitle: '12 aktivitas tersimpan',
                          color: const Color(0xFF3B5BDB),
                          bgColor: const Color(0xFFEAF0FF),
                        ),
                        _MenuItem(
                          icon: Icons.medication_outlined,
                          label: 'Obat Favorit',
                          subtitle: '5 obat disimpan',
                          color: const Color(0xFFE67700),
                          bgColor: const Color(0xFFFFF3E0),
                        ),
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          label: 'Apotek Favorit',
                          subtitle: '2 apotek disimpan',
                          color: const Color(0xFF7B2FBE),
                          bgColor: const Color(0xFFF3E5F5),
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // App Settings
                      _buildSectionTitle('Pengaturan'),
                      const SizedBox(height: 12),
                      _buildMenuCard([
                        _MenuItem(
                          icon: Icons.notifications_none_rounded,
                          label: 'Notifikasi',
                          subtitle: 'Kelola pengingat & pemberitahuan',
                          color: const Color(0xFF059669),
                          bgColor: const Color(0xFFECFDF5),
                        ),
                        _MenuItem(
                          icon: Icons.security_rounded,
                          label: _isGoogleWithoutPassword()
                              ? 'Password Aplikasi'
                              : 'Keamanan & Privasi',
                          subtitle: _isGoogleWithoutPassword()
                              ? 'Tambahkan password khusus SmartFarmasi'
                              : 'Password & data pribadi',
                          color: const Color(0xFF0284C7),
                          bgColor: const Color(0xFFE0F2FE),
                          onTap: _showSecuritySheet,
                        ),
                        _MenuItem(
                          icon: Icons.language_rounded,
                          label: 'Bahasa Aplikasi',
                          subtitle: 'Indonesia',
                          color: const Color(0xFF6B7280),
                          bgColor: const Color(0xFFF3F4F6),
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // Support
                      _buildSectionTitle('Dukungan'),
                      const SizedBox(height: 12),
                      _buildMenuCard([
                        _MenuItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Pusat Bantuan',
                          subtitle: 'FAQ dan panduan penggunaan',
                          color: AppColors.warning,
                          bgColor: const Color(0xFFFFFBEB),
                        ),
                        _MenuItem(
                          icon: Icons.chat_outlined,
                          label: 'Hubungi Kami',
                          subtitle: 'Live chat & email support',
                          color: AppColors.info,
                          bgColor: const Color(0xFFEFF6FF),
                        ),
                        _MenuItem(
                          icon: Icons.star_outline_rounded,
                          label: 'Beri Penilaian',
                          subtitle: 'Bantu tingkatkan aplikasi',
                          color: const Color(0xFFF59E0B),
                          bgColor: const Color(0xFFFFFBEB),
                        ),
                      ]),

                      const SizedBox(height: 32),

                      // Logout Button
                      GestureDetector(
                        onTap: () {
                          _showLogoutDialog();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFECACA),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Keluar Akun',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: Text(
                          'SmartFarmasi v1.0.0',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.heroGradient),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              child: Column(
                children: [
                  // Top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profil Saya',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Avatar
                  Obx(() {
                    final authController = Get.find<AuthController>();
                    final name = authController.userData['name'] ?? 'Guest';
                    final email =
                        authController.userData['email'] ?? 'guest@email.com';
                    final encodedName = Uri.encodeComponent(name);

                    return Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://ui-avatars.com/api/?name=$encodedName&background=fff&color=0B6E4F&size=200',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGlow,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 12),

                  // Verified badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Akun Terverifikasi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('12', 'Analisis', Icons.medical_information_rounded),
          _buildDivider(),
          _buildStatItem('5', 'Scan Obat', Icons.document_scanner_rounded),
          _buildDivider(),
          _buildStatItem('3', 'Apotek', Icons.local_pharmacy_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 50, width: 1, color: const Color(0xFFF0F0F0));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final index = e.key;
          final item = e.value;
          return Column(
            children: [
              _buildMenuItem(item),
              if (index < items.length - 1)
                const Divider(height: 1, indent: 64, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  bool _isGoogleWithoutPassword() {
    final authController = Get.find<AuthController>();
    return authController.userData['provider'] == 'google' &&
        authController.userData['has_password'] != true;
  }

  void _showSecuritySheet() {
    final isGoogleWithoutPassword = _isGoogleWithoutPassword();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Keamanan Akun',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isGoogleWithoutPassword
                  ? 'Akun Google Anda bisa ditambahkan password khusus SmartFarmasi.'
                  : 'Aksi sensitif akan dikonfirmasi dengan OTP email.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSecurityAction(
              icon: Icons.alternate_email_rounded,
              title: 'Ganti Email',
              subtitle: 'Verifikasi email baru dengan OTP',
              onTap: () {
                Get.back();
                _showChangeEmailSheet();
              },
            ),
            const SizedBox(height: 12),
            _buildSecurityAction(
              icon: Icons.lock_reset_rounded,
              title: isGoogleWithoutPassword
                  ? 'Buat Password Aplikasi'
                  : 'Ganti Password',
              subtitle: isGoogleWithoutPassword
                  ? 'Login bisa pakai Google atau email/password'
                  : 'Konfirmasi password baru dengan OTP',
              onTap: () {
                Get.back();
                if (isGoogleWithoutPassword) {
                  final email = Get.find<AuthController>().userData['email']
                      ?.toString();
                  Get.toNamed(
                    AppRoutes.appPassword,
                    arguments: {'email': email ?? ''},
                  );
                } else {
                  _showChangePasswordSheet();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeEmailSheet() {
    final authController = Get.find<AuthController>();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    var otpSent = false;
    var loading = false;
    var obscurePassword = true;
    var cooldownSeconds = 0;
    Timer? resendTimer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void startCooldown() {
            cooldownSeconds = 180;
            resendTimer?.cancel();
            resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (cooldownSeconds > 0) {
                setSheetState(() => cooldownSeconds--);
              } else {
                timer.cancel();
              }
            });
          }

          Future<void> requestOtp() async {
            setSheetState(() => loading = true);
            final success = await authController.requestEmailChangeOtp(
              newEmail: emailCtrl.text,
              currentPassword: passwordCtrl.text,
            );
            if (success) {
              setSheetState(() {
                otpSent = true;
                otpCtrl.clear();
                obscurePassword = true;
              });
              startCooldown();
            }
            setSheetState(() => loading = false);
          }

          Future<void> confirmOtp() async {
            setSheetState(() => loading = true);
            final success = await authController.confirmEmailChange(
              newEmail: emailCtrl.text,
              otp: otpCtrl.text,
            );
            setSheetState(() => loading = false);
            if (success) Get.back();
          }

          return _buildActionSheet(
            title: 'Ganti Email',
            subtitle: 'OTP akan dikirim ke email baru Anda.',
            children: [
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                enabled: !otpSent && !loading,
                decoration: const InputDecoration(
                  labelText: 'Email Baru',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: passwordCtrl,
                obscureText: obscurePassword,
                enabled: !otpSent && !loading,
                decoration: InputDecoration(
                  labelText: 'Password Saat Ini',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: (!otpSent && !loading) 
                        ? () => setSheetState(() => obscurePassword = !obscurePassword)
                        : null,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),
              if (otpSent) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    labelText: 'Kode OTP',
                    prefixIcon: Icon(Icons.password_rounded),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: loading ? null : (otpSent ? confirmOtp : requestOtp),
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        otpSent ? Icons.verified_rounded : Icons.send_rounded,
                      ),
                label: Text(otpSent ? 'Verifikasi Email Baru' : 'Kirim OTP'),
              ),
              if (otpSent) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: (loading || cooldownSeconds > 0) ? null : requestOtp,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(cooldownSeconds > 0 
                      ? 'Kirim Ulang (${cooldownSeconds ~/ 60}:${(cooldownSeconds % 60).toString().padLeft(2, '0')})'
                      : 'Resend Code'),
                ),
              ],
            ],
          );
        },
      ),
    ).whenComplete(() {
      resendTimer?.cancel();
      emailCtrl.dispose();
      passwordCtrl.dispose();
      otpCtrl.dispose();
    });
  }

  void _showChangePasswordSheet() {
    final authController = Get.find<AuthController>();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    var otpSent = false;
    var loading = false;
    var obscureCurrent = true;
    var obscureNew = true;
    var obscureConfirm = true;
    var cooldownSeconds = 0;
    Timer? resendTimer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void startCooldown() {
            cooldownSeconds = 180;
            resendTimer?.cancel();
            resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (cooldownSeconds > 0) {
                setSheetState(() => cooldownSeconds--);
              } else {
                timer.cancel();
              }
            });
          }

          Future<void> requestOtp() async {
            setSheetState(() => loading = true);
            final success = await authController.requestPasswordChangeOtp(
              currentPassword: currentCtrl.text,
              newPassword: newCtrl.text,
              newPasswordConfirmation: confirmCtrl.text,
            );
            if (success) {
              setSheetState(() {
                otpSent = true;
                otpCtrl.clear();
                obscureCurrent = true;
                obscureNew = true;
                obscureConfirm = true;
              });
              startCooldown();
            }
            setSheetState(() => loading = false);
          }

          Future<void> confirmOtp() async {
            setSheetState(() => loading = true);
            final success = await authController.confirmPasswordChange(
              currentPassword: currentCtrl.text,
              newPassword: newCtrl.text,
              newPasswordConfirmation: confirmCtrl.text,
              otp: otpCtrl.text,
            );
            setSheetState(() => loading = false);
            if (success) Get.back();
          }

          return _buildActionSheet(
            title: 'Ganti Password',
            subtitle:
                'Masukkan password lama, password baru, lalu verifikasi OTP.',
            children: [
              _buildPasswordField(
                controller: currentCtrl,
                label: 'Password Saat Ini',
                obscure: obscureCurrent,
                enabled: !otpSent && !loading,
                onToggle: () =>
                    setSheetState(() => obscureCurrent = !obscureCurrent),
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: newCtrl,
                label: 'Password Baru',
                obscure: obscureNew,
                enabled: !otpSent && !loading,
                onToggle: () => setSheetState(() => obscureNew = !obscureNew),
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: confirmCtrl,
                label: 'Konfirmasi Password Baru',
                obscure: obscureConfirm,
                enabled: !otpSent && !loading,
                onToggle: () =>
                    setSheetState(() => obscureConfirm = !obscureConfirm),
              ),
              if (otpSent) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    labelText: 'Kode OTP',
                    prefixIcon: Icon(Icons.password_rounded),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: loading ? null : (otpSent ? confirmOtp : requestOtp),
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        otpSent ? Icons.verified_rounded : Icons.send_rounded,
                      ),
                label: Text(otpSent ? 'Verifikasi Password Baru' : 'Kirim OTP'),
              ),
              if (otpSent) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: (loading || cooldownSeconds > 0) ? null : requestOtp,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(cooldownSeconds > 0 
                      ? 'Kirim Ulang (${cooldownSeconds ~/ 60}:${(cooldownSeconds % 60).toString().padLeft(2, '0')})'
                      : 'Resend Code'),
                ),
              ],
            ],
          );
        },
      ),
    ).whenComplete(() {
      resendTimer?.cancel();
      currentCtrl.dispose();
      newCtrl.dispose();
      confirmCtrl.dispose();
      otpCtrl.dispose();
    });
  }

  Widget _buildActionSheet({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required bool enabled,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: enabled ? onToggle : null,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Keluar dari Akun?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda perlu masuk kembali\nuntuk menggunakan aplikasi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.offAllNamed(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Ya, Keluar'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: const Text('Batalkan'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    required this.bgColor,
    this.onTap,
  });
}
