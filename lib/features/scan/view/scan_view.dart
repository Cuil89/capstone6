import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_ui_components.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final Animation<double> _scanLine;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scanLine = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _simulateScan() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ResultSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showBack = Get.currentRoute == AppRoutes.scan;

    return Scaffold(
      backgroundColor: const Color(0xFF121816),
      body: Stack(
        children: [
          const _CameraPreviewPlaceholder(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: showBack
                        ? _RoundScanButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: Get.back,
                          )
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Text(
                      'Scan obat',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _RoundScanButton(
                    icon: _flashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    active: _flashOn,
                    onTap: () => setState(() => _flashOn = !_flashOn),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const StatusPill(
                    label: 'Live label scan',
                    color: AppColors.primaryGlow,
                    icon: Icons.camera_alt_rounded,
                  ),
                  const SizedBox(height: 16),
                  _ScanFrame(animation: _scanLine),
                  const SizedBox(height: 22),
                  Text(
                    'Arahkan ke label obat',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pastikan nama, kandungan, dan dosis terbaca jelas.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomControls(onScan: _simulateScan),
          ),
        ],
      ),
    );
  }
}

class _CameraPreviewPlaceholder extends StatelessWidget {
  const _CameraPreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF10231E), Color(0xFF08110F)],
            ),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _CameraNoisePainter())),
        Container(color: Colors.black.withValues(alpha: 0.18)),
      ],
    );
  }
}

class _ScanFrame extends StatelessWidget {
  final Animation<double> animation;

  const _ScanFrame({required this.animation});

  @override
  Widget build(BuildContext context) {
    const size = 250.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.82),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGlow.withValues(alpha: 0.16),
                  blurRadius: 34,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryGlow.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return Positioned(
                top: 26 + (size - 52) * animation.value,
                left: 28,
                right: 28,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGlow,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGlow.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final VoidCallback onScan;

  const _BottomControls({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LiquidCard(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(14),
        borderRadius: BorderRadius.circular(26),
        glass: true,
        color: Colors.white.withValues(alpha: 0.86),
        child: Row(
          children: [
            _ControlAction(
              icon: Icons.photo_library_outlined,
              label: 'Galeri',
              onTap: () => _comingSoon('Galeri'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.document_scanner_rounded),
                label: const Text('Scan label'),
              ),
            ),
            const SizedBox(width: 12),
            _ControlAction(
              icon: Icons.history_rounded,
              label: 'Riwayat',
              onTap: () => _comingSoon('Riwayat scan'),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(String title) {
    Get.snackbar(
      title,
      'Fitur ini akan aktif setelah layanan pemindaian tersedia.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }
}

class _ControlAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 58,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundScanButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _RoundScanButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active
              ? AppColors.amber.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(
          icon,
          color: active ? AppColors.amber : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _ResultSheet extends StatelessWidget {
  const _ResultSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/illustrations/scan_guide.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StatusPill(
                        label: 'Label terbaca',
                        color: AppColors.success,
                        icon: Icons.verified_rounded,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Paracetamol 500 mg',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tablet generik',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _DrugInfoRow(label: 'Kandungan', value: 'Paracetamol 500 mg'),
            const _DrugInfoRow(
              label: 'Indikasi',
              value: 'Membantu meredakan demam dan nyeri ringan.',
            ),
            const _DrugInfoRow(
              label: 'Aturan pakai',
              value:
                  'Ikuti petunjuk pada kemasan atau anjuran tenaga kesehatan.',
            ),
            const _DrugInfoRow(label: 'Pabrik', value: 'PT Pharma Indonesia'),
            const SizedBox(height: 10),
            const AppInfoBanner(
              icon: Icons.warning_amber_rounded,
              color: AppColors.amber,
              title: 'Periksa ulang',
              message:
                  'Pastikan hasil sesuai label asli. Jangan gunakan obat jika kemasan rusak atau kedaluwarsa.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: Get.back,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrugInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DrugInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.38,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    for (var i = 0.0; i < size.width; i += 36) {
      canvas.drawLine(Offset(i, 0), Offset(i + 120, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
