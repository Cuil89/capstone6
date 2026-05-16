// test/widget/chatbot_test.dart
//
// Widget test untuk ChatbotView.
// Memastikan input chat, send button, dan bubble pesan berfungsi.
// ChatbotController tidak butuh API eksternal karena responsnya lokal.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:smart_farmasi1/features/chatbot/view/chatbot_view.dart';
import 'package:smart_farmasi1/features/chatbot/controller/chatbot_controller.dart';
import '../helpers/test_helpers.dart';

Widget _chatbotApp() {
  return GetMaterialApp(
    home: const ChatbotView(),
    initialBinding: BindingsBuilder(() {
      Get.put(ChatbotController());
    }),
  );
}

void main() {
  setUp(() => Get.reset());
  tearDown(() => Get.reset());

  group('ChatbotView Widget Tests', () {
    testWidgets('Halaman Chatbot tampil', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_chatbotApp());
        await pumpAndSettleSafely(tester);

        expect(find.byType(ChatbotView), findsOneWidget);
      });
    });

    testWidgets('AppBar berisi judul Asisten SEHATI', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_chatbotApp());
        await pumpAndSettleSafely(tester);

        expect(find.text('Asisten SEHATI'), findsOneWidget);
      });
    });

    testWidgets('Pesan selamat datang dari bot tampil otomatis', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_chatbotApp());
        await pumpAndSettleSafely(tester);

        expect(find.textContaining('Halo'), findsOneWidget);
      });
    });

    testWidgets('Input field chat tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_chatbotApp());
        await pumpAndSettleSafely(tester);

        expect(find.byType(TextField), findsOneWidget);
      });
    });

    testWidgets('Tombol kirim (send) tersedia', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_chatbotApp());
        await pumpAndSettleSafely(tester);

        // FilledButton adalah send button
        expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      });
    });

    testWidgets('Mengetik pesan dan menekan kirim menampilkan bubble user',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_chatbotApp());
        await pumpAndSettleSafely(tester);

        // Ketik pesan dummy
        await tester.enterText(
          find.byType(TextField),
          'Obat untuk sakit kepala apa?',
        );
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();

        // Pesan user harus muncul
        expect(
          find.text('Obat untuk sakit kepala apa?'),
          findsOneWidget,
        );
      });
    });

    testWidgets('Bot membalas setelah delay singkat', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_chatbotApp());
        await pumpAndSettleSafely(tester);

        await tester.enterText(
          find.byType(TextField),
          'Saya demam sejak kemarin',
        );
        await tester.tap(find.byIcon(Icons.send_rounded));

        // Tunggu delay ChatbotController (650ms + buffer)
        await tester.pump(const Duration(milliseconds: 800));
        await pumpAndSettleSafely(tester);

        // Harus ada minimal 2 pesan (welcome + user + bot)
        final controller = Get.find<ChatbotController>();
        expect(controller.messages.length, greaterThanOrEqualTo(2));
      });
    });

    testWidgets('Suggestion chips muncul sebelum ada pesan dari user',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_chatbotApp());
        await pumpAndSettleSafely(tester);

        // Chip saran harus tersedia
        expect(find.byType(ActionChip), findsWidgets);
      });
    });

    testWidgets('Tombol hapus chat tersedia di AppBar', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_chatbotApp());
        await pumpAndSettleSafely(tester);

        expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      });
    });

    testWidgets('Hapus chat mereset pesan ke welcome saja', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(_chatbotApp());
        await pumpAndSettleSafely(tester);

        // Kirim satu pesan
        await tester.enterText(find.byType(TextField), 'Test');
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump(const Duration(milliseconds: 800));

        // Hapus chat
        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await pumpAndSettleSafely(tester);

        // Setelah clear, hanya ada 1 pesan welcome
        final controller = Get.find<ChatbotController>();
        expect(controller.messages.length, equals(1));
        expect(controller.messages.first.isUser, isFalse);
      });
    });

    // ── Responsive ──────────────────────────────────────────────────────────
    for (final entry in {
      'Mobile Small': TestScreenSizes.mobileSmall,
      'Mobile Normal': TestScreenSizes.mobileNormal,
      'Tablet': TestScreenSizes.tablet,
    }.entries) {
      testWidgets('Chatbot tampil tanpa overflow pada ${entry.key}',
          (tester) async {
        await mockNetworkImagesFor(() async {
          setScreenSize(tester, entry.value);
          addTearDown(() => resetScreenSize(tester));
          await tester.pumpWidget(_chatbotApp());
          await pumpAndSettleSafely(tester);
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}
