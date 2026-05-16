// test/widget/health_check_test.dart
//
// Widget test untuk SymptomView (Cek Kesehatan).
// Menggunakan SymptomController asli (tidak butuh backend – data lokal).
// RecommendationController juga lokal.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:smart_farmasi1/features/symptom/view/symptom_view.dart';
import 'package:smart_farmasi1/features/symptom/controller/symptom_controller.dart';
import 'package:smart_farmasi1/features/recommendation/controller/recommendation_controller.dart';
import '../helpers/test_helpers.dart';

Widget _symptomApp() {
  return GetMaterialApp(
    home: const SymptomView(),
    initialBinding: BindingsBuilder(() {
      // Kedua controller tidak butuh network – datanya statis/lokal
      Get.put(SymptomController());
      Get.put(RecommendationController());
    }),
  );
}

void main() {
  setUp(() => Get.reset());
  tearDown(() => Get.reset());

  group('SymptomView (Cek Kesehatan) Widget Tests', () {
    testWidgets('Halaman Cek Kesehatan tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        expect(find.byType(SymptomView), findsOneWidget);
      });
    });

    testWidgets('Header teks Cek gejala tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        expect(find.textContaining('Cek'), findsWidgets);
      });
    });

    testWidgets('Search field tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        expect(find.byType(TextField), findsAtLeastNWidgets(1));
      });
    });

    testWidgets('Gejala Demam tersedia di daftar', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        expect(find.text('Demam'), findsOneWidget);
      });
    });

    testWidgets('Gejala Sakit Kepala tersedia di daftar', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        expect(find.text('Sakit Kepala'), findsOneWidget);
      });
    });

    testWidgets('Gejala Batuk tersedia di daftar', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        expect(find.text('Batuk'), findsOneWidget);
      });
    });

    testWidgets('Memilih gejala menampilkan chip terpilih', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        await tester.tap(find.text('Demam'));
        await pumpAndSettleSafely(tester);

        // Setelah dipilih, "Demam" muncul setidaknya 1x (bisa di grid + tray)
        expect(find.text('Demam'), findsAtLeastNWidgets(1));
        // State controller harus update
        final ctrl = Get.find<SymptomController>();
        expect(ctrl.symptoms.contains('Demam'), isTrue);
      });
    });

    testWidgets('Setelah memilih gejala, tombol Analisis muncul',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        await tester.tap(find.text('Demam'));
        await pumpAndSettleSafely(tester);

        expect(find.textContaining('Analisis'), findsOneWidget);
      });
    });

    testWidgets('Filter kategori Pernapasan tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        expect(find.text('Pernapasan'), findsOneWidget);
      });
    });

    testWidgets('Filter kategori Pencernaan tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        expect(find.text('Pencernaan'), findsOneWidget);
      });
    });

    testWidgets('Memilih gejala kedua menambah jumlah symptoms', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        await tester.tap(find.text('Demam'));
        await pumpAndSettleSafely(tester);
        await tester.tap(find.text('Batuk'));
        await pumpAndSettleSafely(tester);

        final ctrl = Get.find<SymptomController>();
        expect(ctrl.symptoms.length, equals(2));
      });
    });

    testWidgets('Men-tap gejala yang sudah dipilih menghapusnya', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_symptomApp());
        await pumpAndSettleSafely(tester);

        await tester.tap(find.text('Demam'));
        await pumpAndSettleSafely(tester);

        // Tap lagi untuk deselect
        await tester.tap(find.text('Demam'));
        await pumpAndSettleSafely(tester);

        final ctrl = Get.find<SymptomController>();
        expect(ctrl.symptoms.contains('Demam'), isFalse);
      });
    });

    // ── Responsive ──────────────────────────────────────────────────────────
    for (final entry in {
      'Mobile Small': TestScreenSizes.mobileSmall,
      'Mobile Normal': TestScreenSizes.mobileNormal,
      'Tablet': TestScreenSizes.tablet,
    }.entries) {
      testWidgets('Symptom tampil tanpa overflow pada ${entry.key}',
          (tester) async {
        await mockNetworkImagesFor(() async {
          setScreenSize(tester, entry.value);
          addTearDown(() => resetScreenSize(tester));
          await tester.pumpWidget(_symptomApp());
          await pumpAndSettleSafely(tester);
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}
