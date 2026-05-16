import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/disease_news_model.dart';
import '../controller/disease_news_controller.dart';
import 'disease_news_list_view.dart';

class DiseaseNewsSection extends StatelessWidget {
  const DiseaseNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DiseaseNewsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.newspaper_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'News Penyakit Terkini',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            InkWell(
              onTap: () => Get.to(() => const DiseaseNewsListView()),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFE082), width: 1),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Color(0xFFE67700),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Informasi bersifat edukasi. Bukan pengganti konsultasi dokter.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFFE67700),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (ctrl.isLoadingTrending.value) {
            return Column(
              children: List.generate(2, (_) => const _SkeletonCard()),
            );
          }
          if (ctrl.hasError.value && ctrl.trendingNews.isEmpty) {
            return _ErrorState(ctrl: ctrl);
          }
          if (ctrl.trendingNews.isEmpty) {
            return _EmptyState(ctrl: ctrl);
          }

          return Column(
            children: [
              ...ctrl.trendingNews
                  .take(2)
                  .map((news) => _DiseaseNewsCard(news: news)),
              if (ctrl.lastUpdated.value.isNotEmpty) ...[
                const SizedBox(height: 2),
                Center(
                  child: Text(
                    ctrl.lastUpdated.value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }
}

class _DiseaseNewsCard extends StatelessWidget {
  final DiseaseNewsModel news;
  const _DiseaseNewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLink(news.sourceUrl),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NewsThumbnail(news: news, accentColor: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _BadgeWidget(
                            badge: news.badge,
                            alertLevel: news.alertLevel,
                          ),
                          _RegionChip(label: news.regionLabel),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      if (news.summary.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          news.summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          _SourceDot(source: news.sourceName),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MetaItem(
                              icon: Icons.schedule_rounded,
                              label: news.formattedDate,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _ReadButton(
                            color: AppColors.primary,
                            onTap: news.sourceUrl.isEmpty
                                ? null
                                : () => _openLink(news.sourceUrl),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _accentColor => AppColors.primary;

  Future<void> _openLink(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      Get.snackbar(
        'Gagal Membuka Link',
        url,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}

class _NewsThumbnail extends StatelessWidget {
  final DiseaseNewsModel news;
  final Color accentColor;

  const _NewsThumbnail({required this.news, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiProvider.proxiedImageUrl(news.imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 104,
        height: 108,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _CompactImageFallback(color: accentColor),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _CompactImageFallback(
                    color: accentColor,
                    isLoading: true,
                  );
                },
              )
            else
              _CompactImageFallback(color: accentColor),
            Positioned(
              left: 7,
              right: 7,
              bottom: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  news.regionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactImageFallback extends StatelessWidget {
  final Color color;
  final bool isLoading;

  const _CompactImageFallback({required this.color, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.94),
            AppColors.primary.withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.article_rounded,
                size: 28,
                color: Colors.white.withValues(alpha: 0.9),
              ),
      ),
    );
  }
}

class _BadgeWidget extends StatelessWidget {
  final String badge;
  final String alertLevel;

  const _BadgeWidget({required this.badge, required this.alertLevel});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _badgeStyle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            badge,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) get _badgeStyle {
    switch (badge) {
      case 'Trending':
        return (
          const Color(0xFFFFF6E8),
          const Color(0xFF9A6A12),
          Icons.trending_up_rounded,
        );
      case 'Wabah Global':
        return (
          const Color(0xFFFCEDEA),
          const Color(0xFF9F3E2E),
          Icons.warning_amber_rounded,
        );
      case 'Perlu Diwaspadai':
        return (
          const Color(0xFFFFF7E6),
          const Color(0xFF9A6A12),
          Icons.bolt_rounded,
        );
      default:
        return (
          AppColors.primaryLighter,
          AppColors.primary,
          Icons.fiber_new_rounded,
        );
    }
  }
}

class _RegionChip extends StatelessWidget {
  final String label;
  const _RegionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isIndonesia = label == 'Indonesia';
    final color = isIndonesia ? AppColors.primary : const Color(0xFF147D7E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _SourceDot extends StatelessWidget {
  final String source;
  const _SourceDot({required this.source});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 84),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.public_rounded, size: 12, color: AppColors.primaryLight),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              source,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;

  const _ReadButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? AppColors.surfaceVariant : color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Baca',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: onTap == null ? AppColors.textTertiary : Colors.white,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.arrow_forward_rounded,
                size: 13,
                color: onTap == null ? AppColors.textTertiary : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final DiseaseNewsController ctrl;
  const _ErrorState({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 40,
            color: Color(0xFFEF5350),
          ),
          const SizedBox(height: 12),
          Text(
            ctrl.errorMessage.value,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFFC62828),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => ctrl.fetchTrending(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final DiseaseNewsController ctrl;
  const _EmptyState({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.article_outlined,
            size: 42,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada berita terkini',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Data sedang dimuat dari sumber terpercaya...',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => ctrl.fetchTrending(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 0.9).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmer(double.infinity, 152, radius: 0),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _shimmer(76, 22),
                      const SizedBox(width: 8),
                      _shimmer(92, 22),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _shimmer(double.infinity, 16),
                  const SizedBox(height: 7),
                  _shimmer(220, 14),
                  const SizedBox(height: 13),
                  _shimmer(140, 13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer(double w, double h, {double radius = 8}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.grey.withValues(alpha: _anim.value * 0.24),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
