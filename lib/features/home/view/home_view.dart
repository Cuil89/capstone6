import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_ui_components.dart';
import '../../auth/controller/auth_controller.dart';
import 'disease_news_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  const _TopBar(),
                  const SizedBox(height: 28),
                  const _ServiceRow(),
                  const SizedBox(height: 24),
                  const _AIBanner(),
                  const SizedBox(height: 24),
                  const _SafetyStrip(),
                  const SizedBox(height: 24),
                  const DiseaseNewsSection(),
                  const SizedBox(height: 24),
                  const AppSectionHeader(title: 'Aktivitas'),
                  const SizedBox(height: 12),
                  EmptyStateCard(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Mulai dari satu langkah kecil',
                    message:
                        'Cek gejala atau scan label obat. Riwayat akan tampil saat data backend tersedia.',
                    actionLabel: 'Cek gejala',
                    onAction: () => Get.toNamed(AppRoutes.symptom),
                  ),
                  const SizedBox(height: 82),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authController = Get.find<AuthController>();
      final name = authController.userData['name'] ?? 'Guest';
      final firstName = name.toString().trim().split(' ').first;

      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const StatusPill(
                      label: 'SEHATI',
                      color: AppColors.primary,
                      icon: Icons.local_pharmacy_rounded,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '2026',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Hai, $firstName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Get.toNamed(AppRoutes.profile),
            customBorder: const CircleBorder(),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.cardShadow,
              ),
              child: Center(
                child: Text(
                  _initials(name.toString()),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'SH';
    final first = parts.first[0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }
}


class _ServiceRow extends StatelessWidget {
  const _ServiceRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ServiceItem(
          title: 'Gejala',
          icon: Icons.health_and_safety_rounded,
          color: AppColors.primary,
          onTap: () => Get.toNamed(AppRoutes.symptom),
        ),
        _ServiceItem(
          title: 'Scan',
          icon: Icons.document_scanner_rounded,
          color: AppColors.accent,
          onTap: () => Get.toNamed(AppRoutes.scan),
        ),
        _ServiceItem(
          title: 'Asisten',
          icon: Icons.forum_rounded,
          color: AppColors.secondary,
          onTap: () => Get.toNamed(AppRoutes.chatbot),
        ),
        _ServiceItem(
          title: 'Apotek',
          icon: Icons.local_pharmacy_rounded,
          color: AppColors.amber,
          onTap: () => Get.toNamed(AppRoutes.pharmacy),
        ),
      ],
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: GradientIconBox(
                  icon: icon,
                  color: color,
                  size: 44, // Make icon slightly larger inside
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIBanner extends StatelessWidget {
  const _AIBanner();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cio Asisten Dokter',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0B6E4F),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B6E4F).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: 40,
                  child: IgnorePointer(
                    child: SizedBox(
                      height: 190,
                      width: 180,
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.transparent, Colors.white, Colors.white],
                            stops: [0.0, 0.35, 1.0], // Feather the left side
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image.asset(
                          'assets/illustrations/doctor_green.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_pharmacy_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Cio',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Memperkenalkan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cio\nAsisten Dokter',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Material(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => Get.toNamed(AppRoutes.chatbot),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: Text(
                              'Chat dengan Cio',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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
          ),
        ),
      ],
    );
  }
}

class _SafetyStrip extends StatelessWidget {
  const _SafetyStrip();

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(14),
      gradient: const LinearGradient(
        colors: [Color(0xFFFFF7E7), Color(0xFFEFFFF7)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      child: Row(
        children: [
          const GradientIconBox(
            icon: Icons.verified_user_rounded,
            color: AppColors.amber,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Rekomendasi hanya panduan awal. Untuk kondisi berat atau obat resep, konsultasi dengan tenaga kesehatan.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
