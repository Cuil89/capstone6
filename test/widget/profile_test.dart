// test/widget/profile_test.dart
//
// Widget test untuk ProfileView.
// MockAuthController di-register sebagai AuthController.
// FakeProfileController di-register sebagai ProfileController.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:smart_farmasi1/features/profile/view/profile_view.dart';
import 'package:smart_farmasi1/features/profile/controller/profile_controller.dart';
import 'package:smart_farmasi1/features/auth/controller/auth_controller.dart';
import 'package:smart_farmasi1/core/theme/app_theme.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_auth_controller.dart';

// ── FakeProfileController ─────────────────────────────────────────────────────
// Subclass ProfileController; override loadProfile agar tidak hit API.
// Tidak perlu override onInit karena ProfileController tidak punya onInit.
class FakeProfileController extends ProfileController {
  @override
  Future<bool> loadProfile({bool silent = false}) async => true;
}

Widget _profileApp(MockAuthController auth) {
  return GetMaterialApp(
    home: const ProfileView(),
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    initialBinding: BindingsBuilder(() {
      Get.put<AuthController>(auth);
      Get.put<ProfileController>(FakeProfileController());
    }),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
void main() {
  late MockAuthController mockAuth;

  setUp(() {
    Get.reset();
    mockAuth = MockAuthController();
    mockAuth.setLoggedInUser();
  });

  tearDown(() => Get.reset());

  group('ProfileView Widget Tests', () {
    testWidgets('Halaman Profil tampil tanpa crash', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.byType(ProfileView), findsOneWidget);
      });
    });

    testWidgets('Header Profil tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Profil'), findsOneWidget);
      });
    });

    testWidgets('Nama pengguna "Test User" tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Test User'), findsWidgets);
      });
    });

    testWidgets('Email pengguna tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('testuser@example.com'), findsWidgets);
      });
    });

    testWidgets('Badge Akun terverifikasi tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Akun terverifikasi'), findsOneWidget);
      });
    });

    testWidgets('Seksi Akun Saya tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Akun Saya'), findsOneWidget);
      });
    });

    testWidgets('Menu Data Pribadi tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Data Pribadi'), findsOneWidget);
      });
    });

    testWidgets('Seksi Pengaturan tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Pengaturan'), findsOneWidget);
      });
    });

    testWidgets('Seksi Dukungan tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Dukungan'), findsOneWidget);
      });
    });

    testWidgets('Tombol Keluar Akun tampil setelah scroll', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -600),
        );
        await pumpAndSettleSafely(tester);

        expect(find.text('Keluar Akun'), findsOneWidget);
      });
    });

    testWidgets('Versi SEHATI v1.0.0 tampil setelah scroll', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -900),
        );
        await pumpAndSettleSafely(tester);

        expect(find.text('SEHATI v1.0.0'), findsOneWidget);
      });
    });

    // ── Unverified user ────────────────────────────────────────────────────
    testWidgets('Badge Belum terverifikasi tampil untuk user unverified',
        (tester) async {
      await mockNetworkImagesFor(() async {
        // Override userData dengan is_verified: false
        mockAuth.userData.value = {
          'name': 'Unverified User',
          'email': 'unverified@test.com',
          'provider': 'email',
          'has_password': true,
          'is_verified': false,
          'profile_picture_url': '',
        };

        await tester.pumpWidget(_profileApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Belum terverifikasi'), findsOneWidget);
      });
    });

    // ── Responsive ──────────────────────────────────────────────────────────
    for (final entry in {
      'Mobile Small (360×640)': TestScreenSizes.mobileSmall,
      'Mobile Normal (390×844)': TestScreenSizes.mobileNormal,
      'Tablet (768×1024)': TestScreenSizes.tablet,
    }.entries) {
      testWidgets('Profil tidak overflow pada ${entry.key}', (tester) async {
        await mockNetworkImagesFor(() async {
          setScreenSize(tester, entry.value);
          addTearDown(() => resetScreenSize(tester));
          await tester.pumpWidget(_profileApp(mockAuth));
          await pumpAndSettleSafely(tester);
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}
