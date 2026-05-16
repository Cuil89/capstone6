// test/helpers/test_helpers.dart
//
// Shared utilities untuk semua widget test.
// Menyediakan fake controllers, binding helper, dan screen size helper.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_farmasi1/core/theme/app_theme.dart';

/// Bungkus widget dalam GetMaterialApp minimal yang tidak butuh Firebase.
Widget buildTestApp(Widget child) {
  return GetMaterialApp(
    home: child,
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,
  );
}

/// Helper untuk set ukuran layar saat test.
void setScreenSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
}

/// Reset ukuran layar ke default setelah test.
void resetScreenSize(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

/// Ukuran layar standar untuk test responsif.
class TestScreenSizes {
  static const Size mobileSmall = Size(360, 640);
  static const Size mobileNormal = Size(390, 844);
  static const Size tablet = Size(768, 1024);
  static const Size webDesktop = Size(1366, 768);
}

/// Helper untuk pump widget dengan settle yang aman (timeout-safe).
Future<void> pumpAndSettleSafely(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      timeout,
    );
  } catch (_) {
    // Jika timeout (misal karena animasi infinite), lanjut saja.
    await tester.pump();
  }
}

/// Membersihkan semua GetX registrations antara test.
void tearDownGet() {
  Get.reset();
}
