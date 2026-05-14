import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/disease_news_controller.dart';
import '../../../data/models/disease_news_model.dart';

Future<void> _openExternalLink(String url) async {
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

class DiseaseNewsListView extends StatefulWidget {
  const DiseaseNewsListView({super.key});

  @override
  State<DiseaseNewsListView> createState() => _DiseaseNewsListViewState();
}

class _DiseaseNewsListViewState extends State<DiseaseNewsListView> {
  late final DiseaseNewsController _ctrl;
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DiseaseNewsController>();
    _ctrl.fetchAll();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        _ctrl.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── App Bar ──────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppTheme.heroGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🦠 News Penyakit Terkini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sumber resmi WHO, CDC, dan Kemenkes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Search Bar ───────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.softShadow,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: _ctrl.applySearch,
                  decoration: InputDecoration(
                    hintText: 'Cari penyakit, berita...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF9E9E9E),
                    ),
                    suffixIcon: Obx(
                      () => _ctrl.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _ctrl.applySearch('');
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Filter Chips ─────────────────────────────────
          SliverToBoxAdapter(child: _buildFilterChips()),

          // ── Sort + Refresh Row ───────────────────────────
          SliverToBoxAdapter(child: _buildSortRefreshRow()),

          // ── Disclaimer ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: Color(0xFFE67700),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Informasi bersifat edukasi. Selalu kunjungi sumber asli dan konsultasi dokter.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFFE67700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── News List ────────────────────────────────────
          Obx(() {
            if (_ctrl.isLoadingAll.value && _ctrl.allNews.isEmpty) {
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, _) => const _SkeletonCardLarge(),
                    childCount: 4,
                  ),
                ),
              );
            }
            if (_ctrl.allNews.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyState());
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == _ctrl.allNews.length) {
                    return _ctrl.isLoadingAll.value
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const SizedBox(height: 20);
                  }
                  return _NewsListCard(news: _ctrl.allNews[index]);
                }, childCount: _ctrl.allNews.length + 1),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Obx(
        () => Row(
          children: [
            _FilterChip(
              label: 'Semua',
              isSelected:
                  _ctrl.filterLevel.value.isEmpty &&
                  _ctrl.filterSource.value.isEmpty,
              onTap: _ctrl.clearFilters,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: '🔴 Tinggi',
              isSelected: _ctrl.filterLevel.value == 'high',
              selectedColor: const Color(0xFFE53935),
              onTap: () => _ctrl.applyFilter(level: 'high'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: '🟡 Sedang',
              isSelected: _ctrl.filterLevel.value == 'medium',
              selectedColor: const Color(0xFFE67700),
              onTap: () => _ctrl.applyFilter(level: 'medium'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: '🟢 Rendah',
              isSelected: _ctrl.filterLevel.value == 'low',
              selectedColor: const Color(0xFF2E7D32),
              onTap: () => _ctrl.applyFilter(level: 'low'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'WHO',
              isSelected: _ctrl.filterSource.value == 'WHO',
              onTap: () => _ctrl.applyFilter(source: 'WHO'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'CDC',
              isSelected: _ctrl.filterSource.value == 'CDC',
              onTap: () => _ctrl.applyFilter(source: 'CDC'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortRefreshRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Obx(
            () => Text(
              '${_ctrl.allNews.length} berita ditemukan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          // Sort toggle
          Obx(
            () => GestureDetector(
              onTap: () {
                final newSort = _ctrl.sortBy.value == 'latest'
                    ? 'trending'
                    : 'latest';
                _ctrl.applyFilter(sort: newSort);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _ctrl.sortBy.value == 'trending'
                          ? Icons.local_fire_department_rounded
                          : Icons.access_time_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _ctrl.sortBy.value == 'trending' ? 'Trending' : 'Terbaru',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Refresh button
          GestureDetector(
            onTap: () async {
              Get.snackbar(
                'Memperbarui...',
                'Mengambil data berita terbaru dari WHO & CDC',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
              await _ctrl.triggerRefresh();
              _ctrl.fetchAll();
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada berita ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau kata kunci pencarian',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _ctrl.clearFilters,
            child: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FILTER CHIP
// ═══════════════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? AppTheme.softShadow : null,
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NEWS LIST CARD (full-width for list page)
// ═══════════════════════════════════════════════════════════════

class _NewsListCard extends StatelessWidget {
  final DiseaseNewsModel news;
  const _NewsListCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: _accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (news.imageUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 16 / 7.2,
                      child: Image.network(
                        news.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Badge + Source
                Row(
                  children: [
                    _BadgeWidget(
                      badge: news.badge,
                      alertLevel: news.alertLevel,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        news.sourceName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3B5BDB),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Alert level indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  news.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),

                if (news.summary.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    news.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Footer
                Row(
                  children: [
                    if (news.country.isNotEmpty) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          news.country,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      news.formattedDate,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Baca Selengkapnya →',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewsDetailSheet(news: news),
    );
  }

  Color get _accentColor {
    switch (news.alertLevel) {
      case 'high':
        return const Color(0xFFE53935);
      case 'medium':
        return const Color(0xFFE67700);
      default:
        return AppColors.primary;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// NEWS DETAIL BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════

class _NewsDetailSheet extends StatelessWidget {
  final DiseaseNewsModel news;
  const _NewsDetailSheet({required this.news});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Alert banner
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentColor, _accentColor.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _BadgeWidget(badge: news.badge, alertLevel: news.alertLevel),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      news.alertLevel == 'high'
                          ? 'Tingkat Kewaspadaan Tinggi'
                          : news.alertLevel == 'medium'
                          ? 'Tingkat Kewaspadaan Sedang'
                          : 'Informasi Kesehatan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (news.imageUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 8.5,
                          child: Image.network(
                            news.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Title
                    Text(
                      news.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Meta info
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.public_rounded,
                          label: news.sourceName,
                          color: const Color(0xFF3B5BDB),
                        ),
                        if (news.country.isNotEmpty)
                          _MetaChip(
                            icon: Icons.location_on_rounded,
                            label: news.country,
                            color: AppColors.primary,
                          ),
                        _MetaChip(
                          icon: Icons.schedule_rounded,
                          label: news.formattedDate,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Summary
                    if (news.summary.isNotEmpty) ...[
                      Text(
                        'Ringkasan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        news.summary,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Disclaimer
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFE082),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: Color(0xFFE65100),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Disclaimer',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFE65100),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Informasi ini bersifat edukasi dan bukan pengganti '
                            'konsultasi dokter atau tenaga medis profesional. '
                            'Selalu verifikasi dari sumber resmi.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFFBF360C),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Buka sumber button
                    if (news.sourceUrl.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Get.back();
                            await _openExternalLink(news.sourceUrl);
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: Text(
                            'Baca di ${news.sourceName}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _accentColor {
    switch (news.alertLevel) {
      case 'high':
        return const Color(0xFFE53935);
      case 'medium':
        return const Color(0xFFE67700);
      default:
        return AppColors.primary;
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BADGE WIDGET
// ═══════════════════════════════════════════════════════════════

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
          Text(icon, style: const TextStyle(fontSize: 10)),
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

  (Color, Color, String) get _badgeStyle {
    switch (badge) {
      case 'Trending':
        return (const Color(0xFFFFE8E8), const Color(0xFFD32F2F), '🔥');
      case 'Wabah Global':
        return (const Color(0xFFFFEBEE), const Color(0xFFB71C1C), '⚠️');
      case 'Perlu Diwaspadai':
        return (const Color(0xFFFFF3E0), const Color(0xFFE65100), '⚡');
      default:
        return (const Color(0xFFE8F5E9), const Color(0xFF2E7D32), '🆕');
    }
  }
}

class _SkeletonCardLarge extends StatelessWidget {
  const _SkeletonCardLarge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmer(70, 24),
              const SizedBox(width: 8),
              _shimmer(50, 24),
            ],
          ),
          const SizedBox(height: 12),
          _shimmer(double.infinity, 16),
          const SizedBox(height: 6),
          _shimmer(double.infinity, 14),
          const SizedBox(height: 6),
          _shimmer(200, 14),
          const SizedBox(height: 12),
          _shimmer(150, 12),
        ],
      ),
    );
  }

  Widget _shimmer(double w, double h) => Container(
    width: w,
    height: h,
    margin: const EdgeInsets.only(bottom: 2),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
