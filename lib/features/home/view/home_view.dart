import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controller/auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import 'disease_news_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<Offset> _headerSlide;
  late Animation<double> _cardsOpacity;

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
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _cardsOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _cardsController, curve: Curves.easeOut));

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), _cardsController.forward);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── CUSTOM APP BAR / HEADER ───
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _headerSlide,
              child: _buildHeader(context),
            ),
          ),

          // ─── BODY CONTENT ───
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverFadeTransition(
              opacity: _cardsOpacity,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),

                  // ─── QUICK ACTIONS ROW ───
                  _buildSectionTitle('Layanan Cepat'),
                  const SizedBox(height: 16),
                  _buildQuickActions(),

                  const SizedBox(height: 28),

                  // ─── HERO BANNER ───
                  _buildHeroBanner(),

                  const SizedBox(height: 28),

                  // ─── HEALTH TIPS (Horizontal scroll) ───
                  _buildSectionTitle('Tips Kesehatan'),
                  const SizedBox(height: 16),
                  _buildHealthTips(),

                  const SizedBox(height: 28),

                  // ─── NEWS PENYAKIT TERKINI ───
                  const DiseaseNewsSection(),

                  const SizedBox(height: 28),

                  // ─── RECENT ACTIVITY ───
                  _buildSectionTitle('Aktivitas Terakhir'),
                  const SizedBox(height: 16),
                  _buildRecentActivity(),

                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.heroGradient),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Obx(() {
                    final authController = Get.find<AuthController>();
                    final name = authController.userData['name'] ?? 'Guest';
                    final firstName = name.split(' ').isNotEmpty ? name.split(' ')[0] : 'Guest';
                    final encodedName = Uri.encodeComponent(name);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, $firstName! 👋',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Semoga Anda sehat hari ini',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Stack(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 2,
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
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.secondary,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 20),

                  // Search Bar
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Cari obat, gejala, atau apotek...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildQuickActions() {
    final items = [
      _QuickAction(
        icon: Icons.medical_information_rounded,
        label: 'Cek\nGejala',
        bgColor: const Color(0xFFE6F4EF),
        iconColor: AppColors.primary,
        onTap: () => Get.toNamed(AppRoutes.symptom),
      ),
      _QuickAction(
        icon: Icons.document_scanner_rounded,
        label: 'Scan\nObat',
        bgColor: const Color(0xFFEAF0FF),
        iconColor: const Color(0xFF3B5BDB),
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.local_pharmacy_rounded,
        label: 'Apotek\nTerdekat',
        bgColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFE67700),
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.chat_bubble_rounded,
        label: 'Tanya\nAI',
        bgColor: const Color(0xFFF3E5F5),
        iconColor: const Color(0xFF7B2FBE),
        onTap: () {},
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items
          .asMap()
          .entries
          .map((e) => _buildQuickActionItem(e.value, e.key))
          .toList(),
    );
  }

  Widget _buildQuickActionItem(_QuickAction item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + index * 80),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, val, child) {
        return Transform.scale(scale: val, child: child);
      },
      child: GestureDetector(
        onTap: item.onTap,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: item.iconColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(item.icon, color: item.iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.symptom),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B6E4F), Color(0xFF16A085)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.buttonShadow,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '✨ Diagnosis AI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cek Kondisi\nKesehatan Anda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Analisis gejala & dapatkan rekomendasi obat instan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Mulai Analisis →',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Icon(
                Icons.health_and_safety_rounded,
                size: 100,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTips() {
    final tips = [
      _HealthTip(
        title: 'Minum Air Putih 8 Gelas/Hari',
        category: 'Hidrasi',
        emoji: '💧',
        color: const Color(0xFFEAF5FF),
      ),
      _HealthTip(
        title: 'Tidur 7-9 Jam Setiap Malam',
        category: 'Istirahat',
        emoji: '😴',
        color: const Color(0xFFF3E5F5),
      ),
      _HealthTip(
        title: 'Olahraga 30 Menit Per Hari',
        category: 'Aktif',
        emoji: '🏃',
        color: const Color(0xFFE6F4EF),
      ),
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Container(
            width: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tip.color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.emoji, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                Text(
                  tip.category,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      _Activity(
        icon: Icons.medical_information_rounded,
        title: 'Analisis Gejala',
        subtitle: 'Demam, Sakit Kepala',
        time: '2 jam lalu',
        color: AppColors.primaryLighter,
        iconColor: AppColors.primary,
      ),
      _Activity(
        icon: Icons.document_scanner_rounded,
        title: 'Scan Obat',
        subtitle: 'Paracetamol 500mg',
        time: 'Kemarin',
        color: const Color(0xFFEAF0FF),
        iconColor: const Color(0xFF3B5BDB),
      ),
    ];

    return Column(
      children: activities.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: a.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(a.icon, color: a.iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                a.time,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });
}

class _HealthTip {
  final String title;
  final String category;
  final String emoji;
  final Color color;
  const _HealthTip({
    required this.title,
    required this.category,
    required this.emoji,
    required this.color,
  });
}

class _Activity {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final Color iconColor;
  const _Activity({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.iconColor,
  });
}
