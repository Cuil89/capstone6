// test/widget/scan_test.dart
//
// Widget test untuk ScanView.
// ScanView saat ini menggunakan placeholder kamera, sehingga aman untuk diuji.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:smart_farmasi1/features/scan/view/scan_view.dart';
import 'package:smart_farmasi1/core/theme/app_theme.dart';
import '../helpers/test_helpers.dart';

Widget _scanApp() {
  return GetMaterialApp(
    home: const ScanView(),
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
  );
}

void main() {
  setUp(() => Get.reset());
  tearDown(() => Get.reset());

  group('ScanView Widget Tests', () {
    testWidgets('Halaman Scan label obat tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_scanApp());
        await pumpAndSettleSafely(tester);

        expect(find.text('Scan obat'), findsOneWidget);
        expect(find.text('Arahkan ke label obat'), findsOneWidget);
      });
    });

    testWidgets('Tombol Flash tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_scanApp());
        await pumpAndSettleSafely(tester);

        // Cari tombol flash (menggunakan Icon flash_off di awal)
        expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);
        
        // Tap flash
        await tester.tap(find.byIcon(Icons.flash_off_rounded));
        await tester.pump();
        
        // Sekarang harus jadi flash_on
        expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);
      });
    });

    testWidgets('Tombol Galeri dan Riwayat tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_scanApp());
        await pumpAndSettleSafely(tester);

        expect(find.text('Galeri'), findsOneWidget);
        expect(find.text('Riwayat'), findsOneWidget);
      });
    });

    testWidgets('Tombol Scan label tersedia di bawah', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_scanApp());
        await pumpAndSettleSafely(tester);

        expect(find.text('Scan label'), findsOneWidget);
      });
    });

    testWidgets('Menjalankan simulasi scan menampilkan hasil Paracetamol', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_scanApp());
        await pumpAndSettleSafely(tester);

        // Tap tombol Scan label
        await tester.tap(find.text('Scan label'));
        await tester.pumpAndSettle();

        // Bottom sheet hasil scan harus muncul
        expect(find.text('Label terbaca'), findsOneWidget);
        expect(find.text('Paracetamol 500 mg'), findsOneWidget);
        expect(find.text('Aturan pakai'), findsOneWidget);
      });
    });

    testWidgets('Menutup hasil scan mengembalikan ke tampilan kamera', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_scanApp());
        await pumpAndSettleSafely(tester);

        // Buka hasil
        await tester.tap(find.text('Scan label'));
        await tester.pumpAndSettle();

        // Tap Selesai
        await tester.tap(find.text('Selesai'));
        await tester.pumpAndSettle();

        // Bottom sheet harus hilang, kembali ke Scan obat
        expect(find.text('Label terbaca'), findsNothing);
        expect(find.text('Scan obat'), findsOneWidget);
      });
    });

    // ── Responsive ──────────────────────────────────────────────────────────
    for (final entry in {
      'Mobile Small': TestScreenSizes.mobileSmall,
      'Mobile Normal': TestScreenSizes.mobileNormal,
      'Tablet': TestScreenSizes.tablet,
    }.entries) {
      testWidgets('ScanView tidak overflow pada ${entry.key}', (tester) async {
        await mockNetworkImagesFor(() async {
          setScreenSize(tester, entry.value);
          addTearDown(() => resetScreenSize(tester));
          await tester.pumpWidget(_scanApp());
          await pumpAndSettleSafely(tester);
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}
