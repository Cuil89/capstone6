// test/widget/home_test.dart
//
// Widget test untuk HomeView.
// MockAuthController di-register sebagai AuthController.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:smart_farmasi1/features/home/view/home_view.dart';
import 'package:smart_farmasi1/features/auth/controller/auth_controller.dart';
import 'package:smart_farmasi1/core/theme/app_theme.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_auth_controller.dart';

Widget _homeApp(MockAuthController auth) {
  return GetMaterialApp(
    home: const HomeView(),
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    initialBinding: BindingsBuilder(() {
      Get.put<AuthController>(auth);
    }),
  );
}

void main() {
  late MockAuthController mockAuth;

  setUp(() {
    Get.reset();
    mockAuth = MockAuthController();
    mockAuth.setLoggedInUser();
  });

  tearDown(() => Get.reset());

  group('HomeView Widget Tests', () {
    testWidgets('Halaman Beranda tampil tanpa crash', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_homeApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.byType(HomeView), findsOneWidget);
      });
    });

    testWidgets('Menu Gejala (Cek Kesehatan) tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_homeApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Gejala'), findsOneWidget);
      });
    });

    testWidgets('Menu Scan tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_homeApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Scan'), findsOneWidget);
      });
    });

    testWidgets('Menu Asisten (Chatbot) tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_homeApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Asisten'), findsOneWidget);
      });
    });

    testWidgets('Menu Apotek tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_homeApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Apotek'), findsOneWidget);
      });
    });

    testWidgets('Greeting "Hai," tampil dengan nama user', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_homeApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.textContaining('Hai,'), findsOneWidget);
      });
    });

    testWidgets('Banner chatbot Cio tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_homeApp(mockAuth));
        await pumpAndSettleSafely(tester);

        // Cio muncul di banner dan/atau teks lain
        expect(find.textContaining('Cio'), findsWidgets);
      });
    });

    testWidgets('Tombol Chat dengan Cio tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_homeApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Chat dengan Cio'), findsOneWidget);
      });
    });

    testWidgets('Section Tips Kesehatan tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_homeApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.textContaining('Tips'), findsWidgets);
      });
    });

    // ── Tap menu items ───────────────────────────────────────────────────────
    testWidgets('Tap menu Gejala tidak crash (navigasi di-handle oleh GetX)',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_homeApp(mockAuth));
        await pumpAndSettleSafely(tester);

        // Tap Gejala – di test tanpa full routing, hanya pastikan tidak crash
        await tester.tap(find.text('Gejala'));
        await pumpAndSettleSafely(tester);
        expect(tester.takeException(), isNull);
      });
    });

    // ── Responsive ──────────────────────────────────────────────────────────
    for (final entry in {
      'Mobile Small (360×640)': TestScreenSizes.mobileSmall,
      'Mobile Normal (390×844)': TestScreenSizes.mobileNormal,
      'Tablet (768×1024)': TestScreenSizes.tablet,
      'Web Desktop (1366×768)': TestScreenSizes.webDesktop,
    }.entries) {
      testWidgets('Beranda tidak overflow pada ${entry.key}', (tester) async {
        await mockNetworkImagesFor(() async {
          setScreenSize(tester, entry.value);
          addTearDown(() => resetScreenSize(tester));
          await tester.pumpWidget(_homeApp(mockAuth));
          await pumpAndSettleSafely(tester);
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}
