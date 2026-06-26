// test/widget/pharmacy_test.dart
//
// Widget test untuk PharmacyView.
// FakePharmacyController extends PharmacyController dan override onInit()
// agar tidak memanggil Geolocator (hardware).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:smart_farmasi1/features/pharmacy/view/pharmacy_view.dart';
import 'package:smart_farmasi1/features/pharmacy/controller/pharmacy_controller.dart';
import 'package:smart_farmasi1/core/theme/app_theme.dart';
import '../helpers/test_helpers.dart';

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
               isOpen: false,
               rating: 4.3,
               lat: -6.205,
               lng: 106.820,
             ),
             NearbyPharmacy(
               name: 'Apotek Century',
               address: 'Jl. Diponegoro No.21',
               distance: '1.4 km',
               isOpen: true,
               rating: 4.7,
               lat: -6.210,
               lng: 106.825,
             ),
           ];

  // Override onInit untuk mencegah Geolocator dipanggil
  @override
  void onInit() {
    // Sengaja tidak memanggil super.onInit()
  }

  // Override semua Rx state dengan nilai dummy
  @override
  PharmacyState get state => _fakeState;

  @override
  List<NearbyPharmacy> get pharmacies => _fakePharmacies;

  @override
  String get errorMessage => '';

  @override
  String get locationLabel => '-6.2000, 106.8160';

  @override
  Position? get currentPosition => null;

  @override
  Future<void> initLocation() async {}

  @override
  Future<void> openRoute(NearbyPharmacy pharmacy) async {}

  @override
  Future<void> searchAllOnMaps() async {}

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}
}

// ── Helper ────────────────────────────────────────────────────────────────────

Widget _pharmacyApp(FakePharmacyController ctrl) {
  return GetMaterialApp(
    home: const PharmacyView(),
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
    initialBinding: BindingsBuilder(() {
      Get.put<PharmacyController>(ctrl);
    }),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
void main() {
  setUp(() => Get.reset());
  tearDown(() => Get.reset());

  group('PharmacyView Widget Tests', () {
    testWidgets('Halaman Apotek Terdekat tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_pharmacyApp(FakePharmacyController()));
        await pumpAndSettleSafely(tester);

        expect(find.byType(PharmacyView), findsOneWidget);
        expect(find.text('Apotek Terdekat'), findsOneWidget);
      });
    });

    testWidgets('Apotek Kimia Farma tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_pharmacyApp(FakePharmacyController()));
        await pumpAndSettleSafely(tester);

        expect(find.text('Apotek Kimia Farma'), findsOneWidget);
      });
    });

    testWidgets('Apotek K-24 tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_pharmacyApp(FakePharmacyController()));
        await pumpAndSettleSafely(tester);

        expect(find.text('Apotek K-24'), findsOneWidget);
      });
    });

    testWidgets('Apotek Century tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_pharmacyApp(FakePharmacyController()));
        await pumpAndSettleSafely(tester);

        expect(find.text('Apotek Century'), findsOneWidget);
      });
    });

    testWidgets('Status Buka dan Tutup tampil pada apotek berbeda', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_pharmacyApp(FakePharmacyController()));
        await pumpAndSettleSafely(tester);

        expect(find.text('Buka'), findsWidgets);
        expect(find.text('Tutup'), findsOneWidget);
      });
    });

    testWidgets('Ada 3 tombol Lihat Rute (satu per apotek)', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_pharmacyApp(FakePharmacyController()));
        await pumpAndSettleSafely(tester);

        expect(find.text('Lihat Rute'), findsNWidgets(3));
      });
    });

    testWidgets('Tombol Lihat Semua di Google Maps tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_pharmacyApp(FakePharmacyController()));
        await pumpAndSettleSafely(tester);

        expect(find.text('Lihat Semua di Google Maps'), findsOneWidget);
      });
    });

    testWidgets('Label koordinat lokasi tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_pharmacyApp(FakePharmacyController()));
        await pumpAndSettleSafely(tester);

        expect(find.text('-6.2000, 106.8160'), findsOneWidget);
      });
    });

    // ── State variants ────────────────────────────────────────────────────────

    testWidgets('[State: loading] CircularProgressIndicator tampil', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _pharmacyApp(FakePharmacyController(state: PharmacyState.loading)),
        );
        await tester.pump(); // satu frame saja – jangan settle (infinite loop)

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    testWidgets('[State: permissionDenied] tombol Aktifkan Lokasi tampil', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _pharmacyApp(
            FakePharmacyController(state: PharmacyState.permissionDenied),
          ),
        );
        await pumpAndSettleSafely(tester);

        expect(find.text('Izin Lokasi Diperlukan'), findsOneWidget);
        expect(find.text('Aktifkan Lokasi'), findsOneWidget);
        expect(find.text('Cari di Google Maps'), findsOneWidget);
      });
    });

    testWidgets('[State: permissionPermanentlyDenied] info blokir tampil', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _pharmacyApp(
            FakePharmacyController(
              state: PharmacyState.permissionPermanentlyDenied,
            ),
          ),
        );
        await pumpAndSettleSafely(tester);

        expect(find.text('Izin Lokasi Diblokir'), findsOneWidget);
      });
    });

    testWidgets('[State: locationDisabled] pesan layanan lokasi tampil', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _pharmacyApp(
            FakePharmacyController(state: PharmacyState.locationDisabled),
          ),
        );
        await pumpAndSettleSafely(tester);

        expect(find.text('Layanan Lokasi Tidak Aktif'), findsOneWidget);
      });
    });

    testWidgets('[State: error] tombol Coba Lagi tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _pharmacyApp(FakePharmacyController(state: PharmacyState.error)),
        );
        await pumpAndSettleSafely(tester);

        expect(find.text('Gagal Memuat Data Apotek'), findsOneWidget);
        expect(find.text('Coba Lagi'), findsOneWidget);
      });
    });

    // ── Responsive ──────────────────────────────────────────────────────────
    for (final entry in {
      'Mobile Small (360×640)': TestScreenSizes.mobileSmall,
      'Mobile Normal (390×844)': TestScreenSizes.mobileNormal,
      'Tablet (768×1024)': TestScreenSizes.tablet,
    }.entries) {
      testWidgets('Apotek tidak overflow pada ${entry.key}', (tester) async {
        await mockNetworkImagesFor(() async {
          setScreenSize(tester, entry.value);
          addTearDown(() => resetScreenSize(tester));
          await tester.pumpWidget(_pharmacyApp(FakePharmacyController()));
          await pumpAndSettleSafely(tester);
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}
