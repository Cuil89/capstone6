import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/api/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_ui_components.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/profile_controller.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().loadProfile(silent: true);
      }
    });
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
                          subtitle: 'Nama, email, dan info akun',
                          color: AppColors.primary,
                          bgColor: AppColors.primaryLighter,
                          onTap: () => Get.toNamed(AppRoutes.editProfile),
                        ),
                        _MenuItem(
                          icon: Icons.history_rounded,
                          label: 'Riwayat Kesehatan',
                          subtitle: 'Akan terisi setelah ada aktivitas',
                          color: const Color(0xFF3B5BDB),
                          bgColor: const Color(0xFFEAF0FF),
                          onTap: () => _showUnavailable('Riwayat kesehatan'),
                        ),
                        _MenuItem(
                          icon: Icons.medication_outlined,
                          label: 'Obat Favorit',
                          subtitle: 'Simpan obat yang sering dicari',
                          color: const Color(0xFFE67700),
                          bgColor: const Color(0xFFFFF3E0),
                          onTap: () => _showUnavailable('Obat favorit'),
                        ),
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          label: 'Apotek Favorit',
                          subtitle: 'Belum ada apotek tersimpan',
                          color: const Color(0xFF7B2FBE),
                          bgColor: const Color(0xFFF3E5F5),
                          onTap: () => _showUnavailable('Apotek favorit'),
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
                          onTap: () => _showUnavailable('Notifikasi'),
                        ),
                        _MenuItem(
                          icon: Icons.security_rounded,
                          label: _isGoogleWithoutPassword()
                              ? 'Password Aplikasi'
                              : 'Keamanan & Privasi',
                          subtitle: _isGoogleWithoutPassword()
                              ? 'Tambahkan password khusus SEHATI'
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
                          onTap: () => _showUnavailable('Bahasa aplikasi'),
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
                          onTap: () => _showUnavailable('Pusat bantuan'),
                        ),
                        _MenuItem(
                          icon: Icons.chat_outlined,
                          label: 'Hubungi Kami',
                          subtitle: 'Live chat & email support',
                          color: AppColors.info,
                          bgColor: const Color(0xFFEFF6FF),
                          onTap: () => _showUnavailable('Hubungi kami'),
                        ),
                        _MenuItem(
                          icon: Icons.star_outline_rounded,
                          label: 'Beri Penilaian',
                          subtitle: 'Bantu tingkatkan aplikasi',
                          color: const Color(0xFFF59E0B),
                          bgColor: const Color(0xFFFFFBEB),
                          onTap: () => _showUnavailable('Beri penilaian'),
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
                          'SEHATI v1.0.0',
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
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Obx(() {
            final authController = Get.find<AuthController>();
            final name = authController.userData['name'] ?? 'Guest';
            final email = authController.userData['email'] ?? 'guest@email.com';
            final profilePictureUrl = ApiConfig.absoluteUrl(
              authController.userData['profile_picture_url']?.toString() ?? '',
            );
            final isVerified = authController.userData['is_verified'] == true;

            return LiquidCard(
              borderRadius: BorderRadius.circular(30),
              padding: const EdgeInsets.all(18),
              gradient: AppTheme.heroGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Profil',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.toNamed(AppRoutes.editProfile),
                        color: Colors.white,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _buildHeaderAvatar(
                        name: name.toString(),
                        imageUrl: profilePictureUrl,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.74),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildHeaderVerificationBadge(isVerified),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeaderAvatar({required String name, required String imageUrl}) {
    return Container(
      width: 68,
      height: 68,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildHeaderInitials(name),
            )
          : _buildHeaderInitials(name),
    );
  }

  Widget _buildHeaderInitials(String name) {
    return Center(
      child: Text(
        _initials(name),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildHeaderVerificationBadge(bool isVerified) {
    final foreground = isVerified ? AppColors.primary : const Color(0xFF92400E);
    final background = isVerified ? Colors.white : const Color(0xFFFFFBEB);
    final border = isVerified
        ? Colors.white.withValues(alpha: 0.85)
        : const Color(0xFFFDE68A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.warning_amber_rounded,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              isVerified ? 'Akun terverifikasi' : 'Belum terverifikasi',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'SH';
    final first = parts.first[0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  Widget _buildStatsRow() {
    return LiquidCard(
      borderRadius: BorderRadius.circular(26),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan akun',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          const AppInfoBanner(
            icon: Icons.history_toggle_off_rounded,
            color: AppColors.primary,
            message:
                'Aktivitas kesehatan, scan obat, dan apotek favorit akan muncul setelah tersinkron dengan backend.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Cek gejala',
                  'Mulai analisis',
                  Icons.health_and_safety_rounded,
                  () => Get.toNamed(AppRoutes.symptom),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem(
                  'Scan obat',
                  'Baca label',
                  Icons.document_scanner_rounded,
                  () => Get.toNamed(AppRoutes.scan),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: AppColors.outline);
  }

  void _showUnavailable(String title) {
    Get.snackbar(
      title,
      'Fitur ini akan aktif setelah data dan layanan pendukung tersedia.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final index = e.key;
          final item = e.value;
          return Column(
            children: [
              _buildMenuItem(item),
              if (index < items.length - 1) _buildDivider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
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

  BuildContext get _rootContext => Get.context ?? context;

  Future<void> _waitForModalTeardown() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
  }

  String _formatSeconds(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final remainingSeconds = safeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _disposeControllersAfterFrame(List<TextEditingController> controllers) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final controller in controllers) {
        controller.dispose();
      }
    });
  }

  Future<void> _showSecuritySheet() async {
    final isGoogleWithoutPassword = _isGoogleWithoutPassword();
    final action = await showModalBottomSheet<String>(
      context: _rootContext,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
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
                  ? 'Akun Google Anda bisa ditambahkan password khusus SEHATI.'
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
              onTap: () =>
                  Navigator.of(sheetContext, rootNavigator: true).pop('email'),
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
              onTap: () => Navigator.of(
                sheetContext,
                rootNavigator: true,
              ).pop('password'),
            ),
            const SizedBox(height: 12),
            _buildSecurityAction(
              icon: Icons.delete_forever_rounded,
              title: 'Hapus Akun',
              subtitle: 'Nonaktifkan & jadwalkan penghapusan akun',
              iconColor: AppColors.error,
              bgColor: const Color(0xFFFEF2F2),
              onTap: () =>
                  Navigator.of(sheetContext, rootNavigator: true).pop('delete'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;
    await _waitForModalTeardown();
    if (!mounted) return;
    if (action == 'email') {
      _showChangeEmailSheet();
      return;
    }
    if (action == 'password') {
      if (isGoogleWithoutPassword) {
        final email = Get.find<AuthController>().userData['email']?.toString();
        Get.toNamed(AppRoutes.appPassword, arguments: {'email': email ?? ''});
      } else {
        _showChangePasswordSheet();
      }
      return;
    }
    if (action == 'delete') {
      _showDeleteAccountSheet();
    }
  }

  Widget _buildSecurityAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? bgColor,
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
                color: bgColor ?? AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primary),
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

  void _showDeleteAccountSheet() {
    final authController = Get.find<AuthController>();
    final bool hasPassword = authController.userData['has_password'] == true;

    final passwordCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    var otpSent = false;
    var loading = false;
    var obscurePassword = true;
    var cooldownSeconds = 0;
    Timer? resendTimer;
    var sheetOpen = true;

    showModalBottomSheet(
      context: _rootContext,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void safeSetSheetState(VoidCallback fn) {
            if (!sheetOpen || !mounted || !context.mounted) return;
            setSheetState(fn);
          }

          void startCooldown() {
            cooldownSeconds = 180;
            resendTimer?.cancel();
            resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (cooldownSeconds > 0) {
                safeSetSheetState(() => cooldownSeconds--);
              } else {
                timer.cancel();
              }
            });
          }

          Future<void> requestOtp() async {
            safeSetSheetState(() => loading = true);
            final success = await authController.requestDeleteAccountOtp();
            if (success) {
              safeSetSheetState(() {
                otpSent = true;
                otpCtrl.clear();
              });
              startCooldown();
            }
            safeSetSheetState(() => loading = false);
          }

          Future<void> confirmDeletion() async {
            if (hasPassword && passwordCtrl.text.isEmpty) {
              Get.snackbar(
                'Password Wajib',
                'Masukkan password Anda untuk konfirmasi.',
                backgroundColor: Colors.red.shade600,
                colorText: Colors.white,
              );
              return;
            }
            if (!hasPassword && !otpSent) {
              await requestOtp();
              return;
            }
            if (!hasPassword && otpCtrl.text.length < 6) {
              Get.snackbar(
                'OTP Tidak Valid',
                'Masukkan 6 digit kode OTP.',
                backgroundColor: Colors.red.shade600,
                colorText: Colors.white,
              );
              return;
            }

            showDialog<void>(
              context: context,
              useRootNavigator: true,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Konfirmasi Terakhir'),
                content: const Text(
                  'Apakah Anda benar-benar yakin ingin menonaktifkan akun? Anda memiliki 30 hari untuk membatalkan tindakan ini.',
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(dialogContext, rootNavigator: true).pop(),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final deletePassword = hasPassword
                          ? passwordCtrl.text
                          : null;
                      final deleteOtp = !hasPassword ? otpCtrl.text : null;
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                      await Future<void>.delayed(Duration.zero);
                      if (context.mounted) {
                        sheetOpen = false;
                        safeSetSheetState(() => loading = false);
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                      await _waitForModalTeardown();
                      await authController.confirmDeleteAccount(
                        password: deletePassword,
                        otpCode: deleteOtp,
                      );
                    },
                    child: const Text(
                      'Ya, Hapus',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildActionSheet(
            sheetContext: context,
            title: 'Hapus Akun',
            subtitle:
                'Proses ini akan menonaktifkan akun Anda segera. Data akan dihapus permanen setelah masa tenggang 30 hari berakhir.',
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE5C4)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade800,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Peringatan Penting!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Semua data medis & riwayat akan ditangguhkan.\n'
                      '• Akun tidak akan dapat dicari atau diakses.\n'
                      '• Anda punya 30 hari untuk mengaktifkan kembali dengan login kembali.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        height: 1.6,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (hasPassword) ...[
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: obscurePassword,
                  enabled: !loading,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    hintText: 'Masukkan password akun Anda',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => safeSetSheetState(
                        () => obscurePassword = !obscurePassword,
                      ),
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                if (otpSent) ...[
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
                      labelText: 'Kode OTP Konfirmasi',
                      prefixIcon: Icon(Icons.password_rounded),
                    ),
                  ),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Karena Anda login via Google tanpa password, kami akan mengirimkan kode OTP konfirmasi ke email Anda sebelum penghapusan akun.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: loading ? null : confirmDeletion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
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
                        hasPassword
                            ? Icons.delete_forever_rounded
                            : (otpSent
                                  ? Icons.check_circle_outline
                                  : Icons.send_rounded),
                      ),
                label: Text(
                  hasPassword
                      ? 'Hapus Akun Sekarang'
                      : (otpSent
                            ? 'Verifikasi & Hapus Akun'
                            : 'Kirim OTP Penghapusan'),
                ),
              ),
              if (!hasPassword && otpSent) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: (loading || cooldownSeconds > 0)
                      ? null
                      : requestOtp,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    cooldownSeconds > 0
                        ? 'Kirim Ulang (${cooldownSeconds ~/ 60}:${(cooldownSeconds % 60).toString().padLeft(2, '0')})'
                        : 'Kirim Ulang OTP',
                  ),
                ),
              ],
            ],
          );
        },
      ),
    ).whenComplete(() {
      sheetOpen = false;
      resendTimer?.cancel();
      _disposeControllersAfterFrame([passwordCtrl, otpCtrl]);
    });
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
    var sheetOpen = true;

    showModalBottomSheet(
      context: _rootContext,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void safeSetSheetState(VoidCallback fn) {
            if (!sheetOpen || !mounted || !context.mounted) return;
            setSheetState(fn);
          }

          void startCooldown() {
            cooldownSeconds = 180;
            resendTimer?.cancel();
            resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (cooldownSeconds > 0) {
                safeSetSheetState(() => cooldownSeconds--);
              } else {
                timer.cancel();
              }
            });
          }

          Future<void> requestOtp() async {
            safeSetSheetState(() => loading = true);
            final success = await authController.requestEmailChangeOtp(
              newEmail: emailCtrl.text,
              currentPassword: passwordCtrl.text,
            );
            if (success) {
              safeSetSheetState(() {
                otpSent = true;
                otpCtrl.clear();
                obscurePassword = true;
              });
              startCooldown();
            }
            safeSetSheetState(() => loading = false);
          }

          Future<void> confirmOtp() async {
            FocusManager.instance.primaryFocus?.unfocus();
            safeSetSheetState(() => loading = true);
            final success = await authController.confirmEmailChange(
              newEmail: emailCtrl.text,
              otp: otpCtrl.text,
              showSuccessSnackbar: false,
            );
            if (success) {
              sheetOpen = false;
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              await _waitForModalTeardown();
              Get.snackbar(
                'Email Berhasil Diganti',
                'Email akun Anda sudah diperbarui.',
                backgroundColor: Colors.green.shade600,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            safeSetSheetState(() => loading = false);
          }

          return _buildActionSheet(
            sheetContext: context,
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
                        ? () => safeSetSheetState(
                            () => obscurePassword = !obscurePassword,
                          )
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
                  onPressed: (loading || cooldownSeconds > 0)
                      ? null
                      : requestOtp,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    cooldownSeconds > 0
                        ? 'Kirim Ulang (${cooldownSeconds ~/ 60}:${(cooldownSeconds % 60).toString().padLeft(2, '0')})'
                        : 'Resend Code',
                  ),
                ),
              ],
            ],
          );
        },
      ),
    ).whenComplete(() {
      sheetOpen = false;
      resendTimer?.cancel();
      _disposeControllersAfterFrame([emailCtrl, passwordCtrl, otpCtrl]);
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
    var otpExpiresSeconds = 0;
    Timer? resendTimer;
    Timer? expiryTimer;
    var sheetOpen = true;

    showModalBottomSheet(
      context: _rootContext,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void safeSetSheetState(VoidCallback fn) {
            if (!sheetOpen || !mounted || !context.mounted) return;
            setSheetState(fn);
          }

          void startCooldown(int seconds) {
            cooldownSeconds = seconds;
            resendTimer?.cancel();
            resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (cooldownSeconds > 0) {
                safeSetSheetState(() => cooldownSeconds--);
              } else {
                timer.cancel();
              }
            });
          }

          void startExpiry(int seconds) {
            otpExpiresSeconds = seconds;
            expiryTimer?.cancel();
            expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (otpExpiresSeconds > 0) {
                safeSetSheetState(() => otpExpiresSeconds--);
              } else {
                timer.cancel();
              }
            });
          }

          Future<void> requestOtp() async {
            safeSetSheetState(() => loading = true);
            final success = await authController.requestPasswordChangeOtp(
              currentPassword: currentCtrl.text,
              newPassword: newCtrl.text,
              newPasswordConfirmation: confirmCtrl.text,
            );
            if (success) {
              safeSetSheetState(() {
                otpSent = true;
                otpCtrl.clear();
                obscureCurrent = true;
                obscureNew = true;
                obscureConfirm = true;
              });
              startCooldown(authController.lastOtpResendAvailableIn.value);
              startExpiry(authController.lastOtpExpiresIn.value);
            }
            safeSetSheetState(() => loading = false);
          }

          Future<void> confirmOtp() async {
            final otp = otpCtrl.text.trim();
            if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
              Get.snackbar(
                'OTP Tidak Valid',
                'Masukkan 6 digit kode OTP.',
                backgroundColor: Colors.red.shade600,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            if (otpExpiresSeconds <= 0) {
              Get.snackbar(
                'OTP Kedaluwarsa',
                'Kode OTP sudah habis masa berlakunya. Kirim ulang kode.',
                backgroundColor: Colors.red.shade600,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            FocusManager.instance.primaryFocus?.unfocus();
            safeSetSheetState(() => loading = true);
            final success = await authController.confirmPasswordChange(
              currentPassword: currentCtrl.text,
              newPassword: newCtrl.text,
              newPasswordConfirmation: confirmCtrl.text,
              otp: otp,
              showSuccessSnackbar: false,
            );
            if (success) {
              resendTimer?.cancel();
              expiryTimer?.cancel();
              sheetOpen = false;
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              await _waitForModalTeardown();
              Get.snackbar(
                'Password Berhasil Diganti',
                'Gunakan password baru saat login berikutnya.',
                backgroundColor: Colors.green.shade600,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            safeSetSheetState(() => loading = false);
          }

          return _buildActionSheet(
            sheetContext: context,
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
                    safeSetSheetState(() => obscureCurrent = !obscureCurrent),
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: newCtrl,
                label: 'Password Baru',
                obscure: obscureNew,
                enabled: !otpSent && !loading,
                onToggle: () =>
                    safeSetSheetState(() => obscureNew = !obscureNew),
              ),
              const SizedBox(height: 14),
              _buildPasswordField(
                controller: confirmCtrl,
                label: 'Konfirmasi Password Baru',
                obscure: obscureConfirm,
                enabled: !otpSent && !loading,
                onToggle: () =>
                    safeSetSheetState(() => obscureConfirm = !obscureConfirm),
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      otpExpiresSeconds <= 0
                          ? Icons.timer_off_rounded
                          : Icons.timer_outlined,
                      size: 16,
                      color: otpExpiresSeconds <= 0
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      otpExpiresSeconds <= 0
                          ? 'Kode OTP kedaluwarsa. Kirim ulang kode.'
                          : 'Kode berlaku ${_formatSeconds(otpExpiresSeconds)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: otpExpiresSeconds <= 0
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ),
                  ],
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
                  onPressed: (loading || cooldownSeconds > 0)
                      ? null
                      : requestOtp,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    cooldownSeconds > 0
                        ? 'Kirim Ulang (${cooldownSeconds ~/ 60}:${(cooldownSeconds % 60).toString().padLeft(2, '0')})'
                        : 'Resend Code',
                  ),
                ),
              ],
            ],
          );
        },
      ),
    ).whenComplete(() {
      sheetOpen = false;
      resendTimer?.cancel();
      expiryTimer?.cancel();
      _disposeControllersAfterFrame([
        currentCtrl,
        newCtrl,
        confirmCtrl,
        otpCtrl,
      ]);
    });
  }

  Widget _buildActionSheet({
    required BuildContext sheetContext,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    final mediaQuery = MediaQuery.of(sheetContext);
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.88),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                Get.find<AuthController>().logout();
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
