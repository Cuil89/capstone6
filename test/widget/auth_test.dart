// test/widget/auth_test.dart
//
// Widget test untuk LoginView dan RegisterView.
// MockAuthController extends AuthController dan override semua API calls.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:smart_farmasi1/features/auth/view/login_view.dart';
import 'package:smart_farmasi1/features/auth/view/register_view.dart';
import 'package:smart_farmasi1/features/auth/controller/auth_controller.dart';
import 'package:smart_farmasi1/core/theme/app_theme.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_auth_controller.dart';

// ── Builder helpers ───────────────────────────────────────────────────────────

Widget _loginApp(MockAuthController auth) {
  return GetMaterialApp(
    home: LoginView(),
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    initialBinding: BindingsBuilder(() {
      // Daftarkan sebagai AuthController agar Get.find<AuthController>() bekerja
      Get.put<AuthController>(auth);
    }),
  );
}

Widget _registerApp(MockAuthController auth) {
  return GetMaterialApp(
    home: RegisterView(),
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    initialBinding: BindingsBuilder(() {
      Get.put<AuthController>(auth);
    }),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
void main() {
  late MockAuthController mockAuth;

  setUp(() {
    Get.reset();
    mockAuth = MockAuthController();
  });

  tearDown(() {
    Get.reset();
  });

  // ══════════════════════════════════════════════════════════════════════════
  // LOGIN VIEW
  // ══════════════════════════════════════════════════════════════════════════
  group('LoginView Widget Tests', () {
    testWidgets('Halaman Login tampil dengan benar', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.byType(LoginView), findsOneWidget);
      });
    });

    testWidgets('Teks Selamat Datang tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Selamat Datang'), findsOneWidget);
      });
    });

    testWidgets('Hint email tersedia (contoh@email.com)', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('contoh@email.com'), findsOneWidget);
      });
    });

    testWidgets('Hint password tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Masukkan password'), findsOneWidget);
      });
    });

    testWidgets('Tombol Masuk tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Masuk'), findsOneWidget);
      });
    });

    testWidgets('Tombol Google Login tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
      });
    });

    testWidgets('Link Daftar sekarang tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Daftar sekarang'), findsOneWidget);
      });
    });

    testWidgets('Link Lupa password tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Lupa password?'), findsOneWidget);
      });
    });

    // ── Validasi via controller ──────────────────────────────────────────────
    testWidgets('Email kosong → emailError muncul', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        mockAuth.emailController.clear();
        mockAuth.passwordController.clear();
        await mockAuth.login();
        await tester.pump();

        expect(mockAuth.emailError.value, isNotEmpty);
      });
    });

    testWidgets('Email format salah → emailError berisi "valid"', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        mockAuth.emailController.text = 'bukan-email';
        await mockAuth.login();
        await tester.pump();

        expect(mockAuth.emailError.value, contains('valid'));
      });
    });

    testWidgets('Password kosong → passwordError muncul', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        mockAuth.emailController.text = 'testuser@example.com';
        mockAuth.passwordController.clear();
        await mockAuth.login();
        await tester.pump();

        expect(mockAuth.passwordError.value, isNotEmpty);
      });
    });

    testWidgets('Password < 8 karakter → passwordError muncul', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        mockAuth.emailController.text = 'testuser@example.com';
        mockAuth.passwordController.text = '123';
        await mockAuth.login();
        await tester.pump();

        expect(mockAuth.passwordError.value, isNotEmpty);
      });
    });

    testWidgets('Login sukses → isLogin = true', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_loginApp(mockAuth));
        await pumpAndSettleSafely(tester);

        mockAuth.emailController.text = 'testuser@example.com';
        mockAuth.passwordController.text = 'password123';
        await mockAuth.login();
        await tester.pump();

        expect(mockAuth.isLogin.value, isTrue);
        expect(mockAuth.emailError.value, isEmpty);
        expect(mockAuth.passwordError.value, isEmpty);
      });
    });

    // ── Responsive ──────────────────────────────────────────────────────────
    for (final entry in {
      'Mobile Small (360×640)': TestScreenSizes.mobileSmall,
      'Mobile Normal (390×844)': TestScreenSizes.mobileNormal,
      'Tablet (768×1024)': TestScreenSizes.tablet,
      'Web Desktop (1366×768)': TestScreenSizes.webDesktop,
    }.entries) {
      testWidgets('Login tidak overflow pada ${entry.key}', (tester) async {
        await mockNetworkImagesFor(() async {
          setScreenSize(tester, entry.value);
          addTearDown(() => resetScreenSize(tester));
          await tester.pumpWidget(_loginApp(mockAuth));
          await pumpAndSettleSafely(tester);
          expect(tester.takeException(), isNull);
        });
      });
    }
  });

  // ══════════════════════════════════════════════════════════════════════════
  // REGISTER VIEW
  // ══════════════════════════════════════════════════════════════════════════
  group('RegisterView Widget Tests', () {
    testWidgets('Halaman Register tampil dengan benar', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_registerApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.byType(RegisterView), findsOneWidget);
        expect(find.text('Buat Akun Baru'), findsOneWidget);
      });
    });

    testWidgets('Ada minimal 4 TextFormField (nama, email, pw, confirm)',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_registerApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.byType(TextFormField), findsAtLeastNWidgets(4));
      });
    });

    testWidgets('Tombol Buat Akun tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_registerApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Buat Akun'), findsOneWidget);
      });
    });

    testWidgets('Tombol Daftar dengan Google tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_registerApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Daftar dengan Google'), findsOneWidget);
      });
    });

    testWidgets('Nama kosong → nameError muncul', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_registerApp(mockAuth));
        await pumpAndSettleSafely(tester);

        mockAuth.nameController.clear();
        await mockAuth.register();
        await tester.pump();

        expect(mockAuth.nameError.value, isNotEmpty);
      });
    });

    testWidgets('Password tidak cocok → confirmError muncul', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_registerApp(mockAuth));
        await pumpAndSettleSafely(tester);

        mockAuth.nameController.text = 'Test User';
        mockAuth.emailController.text = 'user@test.com';
        mockAuth.passwordController.text = 'password123';
        mockAuth.confirmController.text = 'salahpassword';
        await mockAuth.register();
        await tester.pump();

        expect(mockAuth.confirmError.value, contains('cocok'));
      });
    });

    testWidgets('Semua field valid → tidak ada error', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_registerApp(mockAuth));
        await pumpAndSettleSafely(tester);

        mockAuth.nameController.text = 'Siti Rahayu';
        mockAuth.emailController.text = 'siti@test.com';
        mockAuth.passwordController.text = 'password999';
        mockAuth.confirmController.text = 'password999';
        await mockAuth.register();
        await tester.pump();

        expect(mockAuth.nameError.value, isEmpty);
        expect(mockAuth.emailError.value, isEmpty);
        expect(mockAuth.passwordError.value, isEmpty);
        expect(mockAuth.confirmError.value, isEmpty);
      });
    });

    testWidgets('Link Masuk di sini tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_registerApp(mockAuth));
        await pumpAndSettleSafely(tester);

        expect(find.text('Masuk di sini'), findsOneWidget);
      });
    });

    // ── Responsive ──────────────────────────────────────────────────────────
    for (final entry in {
      'Mobile Small': TestScreenSizes.mobileSmall,
      'Mobile Normal': TestScreenSizes.mobileNormal,
      'Tablet': TestScreenSizes.tablet,
    }.entries) {
      testWidgets('Register tidak overflow pada ${entry.key}', (tester) async {
        await mockNetworkImagesFor(() async {
          setScreenSize(tester, entry.value);
          addTearDown(() => resetScreenSize(tester));
          await tester.pumpWidget(_registerApp(mockAuth));
          await pumpAndSettleSafely(tester);
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}
