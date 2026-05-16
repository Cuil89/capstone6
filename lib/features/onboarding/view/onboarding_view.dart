import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _btnController;
  late Animation<double> _btnScale;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.healing_rounded,
      iconBg: const Color(0xFFE6F4EF),
      iconColor: AppColors.primary,
      title: 'Cek Gejala\nDengan AI',
      description:
          'Masukkan gejala yang Anda rasakan dan dapatkan analisis penyakit serta rekomendasi obat secara instan.',
      decorColor: const Color(0xFF0B6E4F),
    ),
    _OnboardingData(
      icon: Icons.document_scanner_rounded,
      iconBg: const Color(0xFFEAF0FF),
      iconColor: const Color(0xFF3B5BDB),
      title: 'Scan Kemasan\nObat Instan',
      description:
          'Arahkan kamera ke kemasan obat untuk mendapatkan informasi lengkap tentang komposisi dan efek samping.',
      decorColor: const Color(0xFF3B5BDB),
    ),
    _OnboardingData(
      icon: Icons.location_on_rounded,
      iconBg: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFE67700),
      title: 'Apotek Terdekat\nSatu Tap',
      description:
          'Temukan apotek terpercaya di sekitar Anda dengan navigasi langsung untuk membeli obat yang dibutuhkan.',
      decorColor: const Color(0xFFE67700),
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _btnScale = _btnController;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 12),
                child: TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    backgroundColor: AppColors.primaryLighter,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Lewati',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], size, index);
                },
              ),
            ),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // CTA Button
                  GestureDetector(
                    onTapDown: (_) => _btnController.reverse(),
                    onTapUp: (_) {
                      _btnController.forward();
                      _nextPage();
                    },
                    onTapCancel: () => _btnController.forward(),
                    child: ScaleTransition(
                      scale: _btnScale,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.buttonShadow,
                        ),
                        child: Center(
                          child: Text(
                            _currentPage < _pages.length - 1
                                ? 'Lanjutkan'
                                : 'Mulai Sekarang',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
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
    );
  }

  Widget _buildPage(_OnboardingData data, Size size, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - value.abs() * 0.3).clamp(0.0, 1.0);
        }
        return Transform.scale(scale: value, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Illustration Area
              Container(
                width: size.width * 0.5,
                height: size.width * 0.5,
                constraints: const BoxConstraints(
                  maxWidth: 300,
                  maxHeight: 300,
                ),
                decoration: BoxDecoration(
                  color: data.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                    decoration: BoxDecoration(
                      color: data.iconBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: data.iconColor.withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(data.icon, size: 100, color: data.iconColor),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              Text(
                data.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                data.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
  final Color decorColor;

  const _OnboardingData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.decorColor,
  });
}
