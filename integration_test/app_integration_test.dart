// integration_test/app_integration_test.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// Integration Test – SEHATI App (Smart Farmasi)
// ─────────────────────────────────────────────────────────────────────────────
//
// CARA MENJALANKAN:
//   Android/Emulator : flutter test integration_test/app_integration_test.dart -d <device_id>
//   Chrome/Web       : flutter test integration_test/app_integration_test.dart -d chrome
//   Semua sekaligus  : flutter test integration_test/
//
// CATATAN:
//   - Test ini TIDAK menyentuh Firebase atau backend asli.
//   - Kamera dan GPS di-skip karena keterbatasan emulator/browser.
//   - FakePharmacyController override onInit agar Geolocator tidak dipanggil.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:smart_farmasi1/features/onboarding/view/onboarding_view.dart';
import 'package:smart_farmasi1/features/auth/view/login_view.dart';
import 'package:smart_farmasi1/features/auth/view/register_view.dart';
import 'package:smart_farmasi1/features/auth/controller/auth_controller.dart';
import 'package:smart_farmasi1/features/home/view/home_view.dart';
import 'package:smart_farmasi1/features/symptom/view/symptom_view.dart';
import 'package:smart_farmasi1/features/symptom/controller/symptom_controller.dart';
import 'package:smart_farmasi1/features/recommendation/controller/recommendation_controller.dart';
import 'package:smart_farmasi1/features/chatbot/view/chatbot_view.dart';
import 'package:smart_farmasi1/features/chatbot/controller/chatbot_controller.dart';
import 'package:smart_farmasi1/features/pharmacy/view/pharmacy_view.dart';
import 'package:smart_farmasi1/features/pharmacy/controller/pharmacy_controller.dart';
import 'package:smart_farmasi1/core/theme/app_theme.dart';

import '../test/mocks/mock_auth_controller.dart';

// ── FakePharmacyController ────────────────────────────────────────────────────
class FakePharmacyController extends PharmacyController {
  final PharmacyState _fakeState;
  final List<NearbyPharmacy> _fakePharmacies;

  FakePharmacyController({
    PharmacyState state = PharmacyState.loaded,
    List<NearbyPharmacy>? pharmacies,
  }) : _fakeState = state,
       _fakePharmacies =
           pharmacies ??
           const [
             NearbyPharmacy(
               name: 'Apotek Kimia Farma',
               address: 'Jl. Sudirman No.12',
               distance: '0.3 km',
               isOpen: true,
               rating: 4.5,
               lat: -6.200,
               lng: 106.816,
             ),
             NearbyPharmacy(
               name: 'Apotek K-24',
               address: 'Jl. Gatot Subroto No.45',
               distance: '0.7 km',
               isOpen: true,
               rating: 4.3,
               lat: -6.205,
               lng: 106.820,
             ),
           ];

  @override
  void onInit() {} // Blokir Geolocator

  @override
  PharmacyState get state => _fakeState;

  @override
  List<NearbyPharmacy> get pharmacies => _fakePharmacies;

  @override
  String get errorMessage => '';

  @override
  String get locationLabel => '-6.2000, 106.8160';

  @override
  dynamic get currentPosition => null;

  @override
  Future<void> initLocation() async {}

  @override
  Future<void> openRoute(NearbyPharmacy p) async {}

  @override
  Future<void> searchAllOnMaps() async {}

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}
}

// ── Settle helper ─────────────────────────────────────────────────────────────
Future<void> _settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 8),
    );
  } catch (_) {
    await tester.pump();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthController mockAuth;

  setUp(() {
    Get.reset();
    mockAuth = MockAuthController();
  });

  tearDown(() => Get.reset());

  // ══════════════════════════════════════════════════════════════════════════
  // FLOW 1 – Onboarding
  // ══════════════════════════════════════════════════════════════════════════
  group('[Flow 1] Onboarding', () {
    testWidgets('Seluruh slide bisa dilewati dengan Lanjutkan', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: const OnboardingView(),
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
          ),
        );
        await _settle(tester);

        // Slide 1 → 2 → 3
        await tester.tap(find.text('Lanjutkan'));
        await _settle(tester);
        await tester.tap(find.text('Lanjutkan'));
        await _settle(tester);

        expect(find.text('Mulai Sekarang'), findsOneWidget);
      });
    });

    testWidgets('Tombol Lewati tidak crash', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: const OnboardingView(),
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
          ),
        );
        await _settle(tester);

        await tester.tap(find.text('Lewati'));
        await _settle(tester);

        expect(tester.takeException(), isNull);
      });
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // FLOW 2 – Login (Happy Path + Error States)
  // ══════════════════════════════════════════════════════════════════════════
  group('[Flow 2] Login', () {
    testWidgets('Email kosong → emailError muncul', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: LoginView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<AuthController>(mockAuth);
            }),
          ),
        );
        await _settle(tester);

        mockAuth.emailController.clear();
        mockAuth.passwordController.clear();
        await mockAuth.login();
        await tester.pump();

        expect(mockAuth.emailError.value, isNotEmpty);
      });
    });

    testWidgets('Email format salah → error format', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: LoginView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<AuthController>(mockAuth);
            }),
          ),
        );
        await _settle(tester);

        mockAuth.emailController.text = 'bukanemailvalid';
        await mockAuth.login();
        await tester.pump();

        expect(mockAuth.emailError.value, contains('valid'));
      });
    });

    testWidgets('Password < 8 karakter → error password', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: LoginView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<AuthController>(mockAuth);
            }),
          ),
        );
        await _settle(tester);

        mockAuth.emailController.text = 'testuser@example.com';
        mockAuth.passwordController.text = '123';
        await mockAuth.login();
        await tester.pump();

        expect(mockAuth.passwordError.value, isNotEmpty);
      });
    });

    testWidgets('Kredensial valid → isLogin = true', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: LoginView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<AuthController>(mockAuth);
            }),
          ),
        );
        await _settle(tester);

        mockAuth.emailController.text = 'testuser@example.com';
        mockAuth.passwordController.text = 'password123';
        await mockAuth.login();
        await tester.pump();

        expect(mockAuth.isLogin.value, isTrue);
        expect(mockAuth.emailError.value, isEmpty);
        expect(mockAuth.passwordError.value, isEmpty);
      });
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // FLOW 3 – Register
  // ══════════════════════════════════════════════════════════════════════════
  group('[Flow 3] Register', () {
    testWidgets('Nama kosong → nameError muncul', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: RegisterView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<AuthController>(mockAuth);
            }),
          ),
        );
        await _settle(tester);

        mockAuth.nameController.clear();
        await mockAuth.register();
        await tester.pump();

        expect(mockAuth.nameError.value, isNotEmpty);
      });
    });

    testWidgets('Password tidak cocok → confirmError muncul', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: RegisterView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<AuthController>(mockAuth);
            }),
          ),
        );
        await _settle(tester);

        mockAuth.nameController.text = 'Budi';
        mockAuth.emailController.text = 'budi@test.com';
        mockAuth.passwordController.text = 'rahasia123';
        mockAuth.confirmController.text = 'berbeda999';
        await mockAuth.register();
        await tester.pump();

        expect(mockAuth.confirmError.value, contains('cocok'));
      });
    });

    testWidgets('Semua valid → tidak ada error', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: RegisterView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<AuthController>(mockAuth);
            }),
          ),
        );
        await _settle(tester);

        mockAuth.nameController.text = 'Siti Rahayu';
        mockAuth.emailController.text = 'siti@test.com';
        mockAuth.passwordController.text = 'password999';
        mockAuth.confirmController.text = 'password999';
        await mockAuth.register();
        await tester.pump();

        expect(mockAuth.nameError.value, isEmpty);
        expect(mockAuth.emailError.value, isEmpty);
        expect(mockAuth.confirmError.value, isEmpty);
      });
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // FLOW 4 – Beranda
  // ══════════════════════════════════════════════════════════════════════════
  group('[Flow 4] Beranda', () {
    testWidgets('Semua 4 menu layanan tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        mockAuth.setLoggedInUser();
        await tester.pumpWidget(
          GetMaterialApp(
            home: const HomeView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<AuthController>(mockAuth);
            }),
          ),
        );
        await _settle(tester);

        expect(find.text('Gejala'), findsOneWidget);
        expect(find.text('Scan'), findsOneWidget);
        expect(find.text('Asisten'), findsOneWidget);
        expect(find.text('Apotek'), findsOneWidget);
      });
    });

    testWidgets('Tombol Chat dengan Cio tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        mockAuth.setLoggedInUser();
        await tester.pumpWidget(
          GetMaterialApp(
            home: const HomeView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<AuthController>(mockAuth);
            }),
          ),
        );
        await _settle(tester);

        expect(find.text('Chat dengan Cio'), findsOneWidget);
      });
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // FLOW 5 – Cek Kesehatan
  // ══════════════════════════════════════════════════════════════════════════
  group('[Flow 5] Cek Kesehatan', () {
    testWidgets('Pilih 3 gejala → analisis menghasilkan rekomendasi', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: const SymptomView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put(SymptomController());
              Get.put(RecommendationController());
            }),
          ),
        );
        await _settle(tester);

        await tester.tap(find.text('Demam'));
        await _settle(tester);
        await tester.tap(find.text('Sakit Kepala'));
        await _settle(tester);
        await tester.tap(find.text('Pilek'));
        await _settle(tester);

        final symptomCtrl = Get.find<SymptomController>();
        expect(symptomCtrl.symptoms.length, equals(3));

        final recCtrl = Get.find<RecommendationController>();
        recCtrl.generateRecommendation(symptomCtrl.symptoms.toList());
        await tester.pump();

        expect(recCtrl.results.isNotEmpty, isTrue);
      });
    });

    testWidgets('Toggle gejala (pilih lalu batalkan) bekerja', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: const SymptomView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put(SymptomController());
              Get.put(RecommendationController());
            }),
          ),
        );
        await _settle(tester);

        await tester.tap(find.text('Batuk'));
        await _settle(tester);
        expect(
          Get.find<SymptomController>().symptoms.contains('Batuk'),
          isTrue,
        );

        await tester.tap(find.text('Batuk'));
        await _settle(tester);
        expect(
          Get.find<SymptomController>().symptoms.contains('Batuk'),
          isFalse,
        );
      });
    });

    testWidgets('Search filter "mual" menampilkan gejala Mual', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: const SymptomView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put(SymptomController());
              Get.put(RecommendationController());
            }),
          ),
        );
        await _settle(tester);

        await tester.enterText(find.byType(TextField).first, 'mual');
        await _settle(tester);

        expect(find.text('Mual'), findsOneWidget);
      });
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // FLOW 6 – Chatbot
  // ══════════════════════════════════════════════════════════════════════════
  group('[Flow 6] Chatbot', () {
    testWidgets('Kirim pesan "demam" → bot membalas dengan info demam', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: const ChatbotView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put(ChatbotController());
            }),
          ),
        );
        await _settle(tester);

        await tester.enterText(find.byType(TextField), 'demam sudah 2 hari');
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump(const Duration(milliseconds: 900));
        await _settle(tester);

        final ctrl = Get.find<ChatbotController>();
        expect(ctrl.messages.length, greaterThanOrEqualTo(3));

        final botReplies = ctrl.messages.where((m) => !m.isUser).toList();
        expect(
          botReplies.any((m) => m.content.toLowerCase().contains('demam')),
          isTrue,
        );
      });
    });

    testWidgets('Hapus chat mereset ke 1 pesan welcome', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: const ChatbotView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put(ChatbotController());
            }),
          ),
        );
        await _settle(tester);

        await tester.enterText(find.byType(TextField), 'Test pesan');
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump(const Duration(milliseconds: 900));

        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await _settle(tester);

        final ctrl = Get.find<ChatbotController>();
        expect(ctrl.messages.length, equals(1));
        expect(ctrl.messages.first.content.contains('Halo'), isTrue);
      });
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // FLOW 7 – Apotek Terdekat
  // ══════════════════════════════════════════════════════════════════════════
  group('[Flow 7] Apotek Terdekat', () {
    testWidgets('Daftar apotek dummy tampil lengkap', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: const PharmacyView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<PharmacyController>(FakePharmacyController());
            }),
          ),
        );
        await _settle(tester);

        expect(find.text('Apotek Kimia Farma'), findsOneWidget);
        expect(find.text('Apotek K-24'), findsOneWidget);
        expect(find.text('Lihat Rute'), findsNWidgets(2));
      });
    });

    testWidgets('[permissionDenied] tombol Aktifkan Lokasi tampil', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: const PharmacyView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<PharmacyController>(
                FakePharmacyController(state: PharmacyState.permissionDenied),
              );
            }),
          ),
        );
        await _settle(tester);

        expect(find.text('Izin Lokasi Diperlukan'), findsOneWidget);
        expect(find.text('Aktifkan Lokasi'), findsOneWidget);
      });
    });

    testWidgets('[error] tombol Coba Lagi tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          GetMaterialApp(
            home: const PharmacyView(),
            theme: AppTheme.lightTheme,
            initialBinding: BindingsBuilder(() {
              Get.put<PharmacyController>(
                FakePharmacyController(state: PharmacyState.error),
              );
            }),
          ),
        );
        await _settle(tester);

        expect(find.text('Coba Lagi'), findsOneWidget);
      });
    });
  });
}
