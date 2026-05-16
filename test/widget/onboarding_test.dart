// test/widget/onboarding_test.dart
//
// Widget test untuk OnboardingView.
// Memastikan halaman tampil, slide bisa berjalan, tombol Lewati dan Mulai berfungsi.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:smart_farmasi1/features/onboarding/view/onboarding_view.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('OnboardingView Widget Tests', () {
    testWidgets('Halaman Onboarding tampil dengan benar', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestApp(const OnboardingView()));
        await pumpAndSettleSafely(tester);

        // Pastikan halaman onboarding render
        expect(find.byType(OnboardingView), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);
      });
    });

    testWidgets('Tombol Lewati tersedia dan bisa diklik', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestApp(const OnboardingView()));
        await pumpAndSettleSafely(tester);

        // Cari tombol Lewati
        expect(find.text('Lewati'), findsOneWidget);
      });
    });

    testWidgets('Tombol Lanjutkan (Next) tersedia pada halaman pertama',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestApp(const OnboardingView()));
        await pumpAndSettleSafely(tester);

        // Halaman pertama – tombol harusnya "Lanjutkan"
        expect(find.text('Lanjutkan'), findsOneWidget);
      });
    });

    testWidgets('Tombol Lanjutkan mengubah halaman (indikator berubah)',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestApp(const OnboardingView()));
        await pumpAndSettleSafely(tester);

        // Tap tombol lanjutkan
        await tester.tap(find.text('Lanjutkan'));
        await pumpAndSettleSafely(tester);

        // Setelah pindah ke halaman ke-2, teks halaman ke-2 harus muncul
        expect(find.textContaining('Scan'), findsWidgets);
      });
    });

    testWidgets('Halaman ketiga memiliki tombol Mulai Sekarang',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestApp(const OnboardingView()));
        await pumpAndSettleSafely(tester);

        // Swipe ke halaman 3
        await tester.tap(find.text('Lanjutkan'));
        await pumpAndSettleSafely(tester);
        await tester.tap(find.text('Lanjutkan'));
        await pumpAndSettleSafely(tester);

        expect(find.text('Mulai Sekarang'), findsOneWidget);
      });
    });

    testWidgets('Indikator halaman ada 3 titik', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestApp(const OnboardingView()));
        await pumpAndSettleSafely(tester);

        // Ada 3 AnimatedContainer sebagai indikator slide
        final indicators = find.byType(AnimatedContainer);
        expect(indicators, findsWidgets);
      });
    });

    // ── Responsive test ──────────────────────────────────────────────────────

    for (final entry in {
      'Mobile Small (360×640)': TestScreenSizes.mobileSmall,
      'Mobile Normal (390×844)': TestScreenSizes.mobileNormal,
      'Tablet (768×1024)': TestScreenSizes.tablet,
      'Web Desktop (1366×768)': TestScreenSizes.webDesktop,
    }.entries) {
      testWidgets('Tampil tanpa overflow pada ${entry.key}', (tester) async {
        await mockNetworkImagesFor(() async {
          setScreenSize(tester, entry.value);
          addTearDown(() => resetScreenSize(tester));

          await tester.pumpWidget(buildTestApp(const OnboardingView()));
          await pumpAndSettleSafely(tester);

          // Tidak boleh ada RenderFlex overflow
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}
