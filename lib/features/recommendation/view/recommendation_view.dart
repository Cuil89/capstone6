import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_ui_components.dart';
import '../../../core/routes/app_routes.dart';
import '../controller/recommendation_controller.dart';

class RecommendationView extends StatelessWidget {
  const RecommendationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecommendationController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Arahan obat'),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Obx(() {
        if (controller.results.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: EmptyStateCard(
                icon: Icons.medication_outlined,
                assetPath: 'assets/illustrations/symptom_empty.png',
                title: 'Belum ada rekomendasi',
                message:
                    'Pilih beberapa gejala yang paling sesuai agar SEHATI bisa menampilkan arahan obat.',
                actionLabel: 'Pilih gejala',
                onAction: Get.back,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          itemCount: controller.results.length + 2,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ResultHero(count: controller.results.length);
            }
            if (index == 1) {
              return const AppInfoBanner(
                icon: Icons.health_and_safety_rounded,
                title: 'Gunakan dengan bijak',
                color: AppColors.amber,
                message:
                    'Rekomendasi ini bersifat edukasi. Segera konsultasi jika gejala berat, berulang, atau tidak membaik.',
              );
            }

            final item = controller.results[index - 2];
            return _MedicineCard(item: item);
          },
        );
      }),
    );
  }
}

class _ResultHero extends StatelessWidget {
  final int count;

  const _ResultHero({required this.count});

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(18),
      gradient: AppTheme.blueGradient,
      child: Row(
        children: [
          const GradientIconBox(
            icon: Icons.medication_liquid_rounded,
            color: AppColors.cyan,
            size: 54,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count opsi ditemukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 21,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Diurutkan dari kecocokan gejala tertinggi.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.78),
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

class _MedicineCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _MedicineCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final score = item['score'] as double;
    final scorePercent = (score * 100).round();
    final scoreColor = score >= 0.75
        ? AppColors.success
        : score >= 0.45
        ? AppColors.amber
        : AppColors.error;
    final matched = (item['matchedSymptoms'] as List<dynamic>? ?? const [])
        .cast<String>();

    return LiquidCard(
      borderRadius: BorderRadius.circular(26),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GradientIconBox(
                  icon: Icons.medication_rounded,
                  color: AppColors.primary,
                  size: 50,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'].toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['type'].toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(
                  label: '$scorePercent%',
                  color: scoreColor,
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: score,
                minHeight: 8,
                color: scoreColor,
                backgroundColor: AppColors.surfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              item['reason'].toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          if (matched.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: matched
                    .map(
                      (symptom) =>
                          StatusPill(label: symptom, color: AppColors.accent),
                    )
                    .toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Indikasi',
                  value: item['indication'].toString(),
                ),
                _InfoRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Aturan pakai',
                  value: item['dose'].toString(),
                ),
                _InfoRow(
                  icon: Icons.personal_injury_outlined,
                  label: 'Efek samping',
                  value: item['side_effect'].toString(),
                ),
                const SizedBox(height: 10),
                AppInfoBanner(
                  icon: Icons.warning_amber_rounded,
                  title: 'Perhatian',
                  color: AppColors.error,
                  message: item['warning'].toString(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.pharmacy),
                        icon: const Icon(Icons.local_pharmacy_rounded, size: 18),
                        label: const Text('Cari Apotek'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showUnavailable('Detail obat'),
                        icon: const Icon(Icons.article_outlined, size: 18),
                        label: const Text('Detail obat'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUnavailable(String title) {
    Get.snackbar(
      title,
      'Fitur ini akan aktif setelah data obat dan apotek tersedia.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
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
}
