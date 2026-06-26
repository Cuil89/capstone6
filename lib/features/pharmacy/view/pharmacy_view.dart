import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_ui_components.dart';
import '../controller/pharmacy_controller.dart';

class PharmacyView extends StatelessWidget {
  const PharmacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PharmacyController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Apotek Terdekat'),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          Obx(() {
            if (controller.state == PharmacyState.loaded) {
              return IconButton(
                onPressed: controller.initLocation,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh lokasi',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() => _buildBody(controller)),
    );
  }

  Widget _buildBody(PharmacyController controller) {
    switch (controller.state) {
      case PharmacyState.initial:
      case PharmacyState.requestingPermission:
        return const _LoadingState(message: 'Memeriksa izin lokasi...');

      case PharmacyState.loading:
        return const _LoadingState(message: 'Mencari apotek terdekat...');

      case PharmacyState.locationDisabled:
        return _PermissionState(
          icon: Icons.location_off_rounded,
          title: 'Layanan Lokasi Tidak Aktif',
          message:
              'Aktifkan layanan lokasi di perangkat Anda untuk menemukan apotek terdekat.',
          actionLabel: 'Buka Pengaturan Lokasi',
          onAction: controller.openLocationSettings,
          secondaryLabel: 'Cari di Google Maps',
          onSecondary: controller.searchAllOnMaps,
        );

      case PharmacyState.permissionDenied:
        return _PermissionState(
          icon: Icons.location_disabled_rounded,
          title: 'Izin Lokasi Diperlukan',
          message:
              'Aktifkan izin lokasi untuk menemukan apotek terdekat berdasarkan posisi Anda saat ini.',
          actionLabel: 'Aktifkan Lokasi',
          onAction: controller.initLocation,
          secondaryLabel: 'Cari di Google Maps',
          onSecondary: controller.searchAllOnMaps,
        );

      case PharmacyState.permissionPermanentlyDenied:
        return _PermissionState(
          icon: Icons.lock_outline_rounded,
          title: 'Izin Lokasi Diblokir',
          message:
              'Izin lokasi telah diblokir secara permanen. Buka pengaturan aplikasi untuk mengaktifkannya.',
          actionLabel: 'Buka Pengaturan Aplikasi',
          onAction: controller.openAppSettings,
          secondaryLabel: 'Cari di Google Maps',
          onSecondary: controller.searchAllOnMaps,
        );

      case PharmacyState.error:
        return _ErrorState(
          message: controller.errorMessage,
          onRetry: controller.initLocation,
          onMaps: controller.searchAllOnMaps,
        );

      case PharmacyState.loaded:
        return _PharmacyList(controller: controller);
    }
  }
}

// ─── Loading State ──────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  final String message;
  const _LoadingState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Permission / Location Disabled State ───────────────────────────────────

class _PermissionState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  const _PermissionState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 38, color: AppColors.amber),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.location_on_rounded, size: 18),
            label: Text(actionLabel),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onSecondary,
            icon: const Icon(Icons.map_rounded, size: 18),
            label: Text(secondaryLabel),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onMaps;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.onMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 38,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Gagal Memuat Data Apotek',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message.isNotEmpty
                ? message
                : 'Terjadi kesalahan saat memuat data. Silakan coba lagi.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onMaps,
            icon: const Icon(Icons.map_rounded, size: 18),
            label: const Text('Cari di Google Maps'),
          ),
        ],
      ),
    );
  }
}

// ─── Pharmacy List (Loaded State) ────────────────────────────────────────────

class _PharmacyList extends StatelessWidget {
  final PharmacyController controller;
  const _PharmacyList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final pharmacies = controller.pharmacies;

    if (pharmacies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: EmptyStateCard(
            icon: Icons.local_pharmacy_outlined,
            title: 'Belum ada apotek ditemukan',
            message:
                'Belum ada apotek terdekat yang ditemukan di sekitar lokasi Anda saat ini.',
            actionLabel: 'Cari di Google Maps',
            onAction: controller.searchAllOnMaps,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      itemCount: pharmacies.length + 2,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) return _LocationHeader(controller: controller);
        if (index == 1) return _MapsSearchButton(controller: controller);
        return _PharmacyCard(
          pharmacy: pharmacies[index - 2],
          onRoute: () => controller.openRoute(pharmacies[index - 2]),
        );
      },
    );
  }
}

// ─── Location Header ─────────────────────────────────────────────────────────

class _LocationHeader extends StatelessWidget {
  final PharmacyController controller;
  const _LocationHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(14),
      gradient: const LinearGradient(
        colors: [Color(0xFFEFFFF7), Color(0xFFFFF7E7)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      child: Row(
        children: [
          const GradientIconBox(
            icon: Icons.my_location_rounded,
            color: AppColors.primary,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi Anda',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.locationLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.initLocation,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Maps Search Button ───────────────────────────────────────────────────────

class _MapsSearchButton extends StatelessWidget {
  final PharmacyController controller;
  const _MapsSearchButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: controller.searchAllOnMaps,
      icon: const Icon(Icons.map_rounded, size: 18),
      label: const Text('Lihat Semua di Google Maps'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

// ─── Pharmacy Card ────────────────────────────────────────────────────────────

class _PharmacyCard extends StatelessWidget {
  final NearbyPharmacy pharmacy;
  final VoidCallback onRoute;

  const _PharmacyCard({required this.pharmacy, required this.onRoute});

  @override
  Widget build(BuildContext context) {
    final isOpen = pharmacy.isOpen;
    final statusColor = isOpen == true ? AppColors.success : AppColors.error;
    final statusLabel = isOpen == true ? 'Buka' : 'Tutup';

    return LiquidCard(
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ikon + nama + status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GradientIconBox(
                  icon: Icons.local_pharmacy_rounded,
                  color: AppColors.primary,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        pharmacy.address,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOpen != null)
                  StatusPill(label: statusLabel, color: statusColor),
              ],
            ),

            const SizedBox(height: 12),

            // Info row: jarak + rating
            Row(
              children: [
                _InfoChip(
                  icon: Icons.directions_walk_rounded,
                  label: pharmacy.distance,
                  color: AppColors.accent,
                ),
                if (pharmacy.rating != null) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.star_rounded,
                    label: pharmacy.rating!.toStringAsFixed(1),
                    color: AppColors.amber,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 14),

            // Tombol Lihat Rute
            ElevatedButton.icon(
              onPressed: onRoute,
              icon: const Icon(Icons.directions_rounded, size: 18),
              label: const Text('Lihat Rute'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
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
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
