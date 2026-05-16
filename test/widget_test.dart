import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_farmasi1/main.dart';
import 'package:smart_farmasi1/core/routes/app_routes.dart';
import 'package:smart_farmasi1/features/auth/controller/auth_controller.dart';
import 'package:smart_farmasi1/features/symptom/controller/symptom_controller.dart';

void main() {
  group('App Widget Tests', () {
    setUpAll(() {
      Get.testMode = true;
    });

    testWidgets('App renders without errors', (WidgetTester tester) async {
      Get.reset();
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    group('Login View Tests', () {
      testWidgets('Login view displays form fields', (
        WidgetTester tester,
      ) async {
        Get.reset();
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        Get.offAllNamed(AppRoutes.login);
        await tester.pumpAndSettle();

        expect(find.text('SEHATI'), findsOneWidget);
        expect(find.text('Selamat Datang'), findsOneWidget);
        expect(
          find.byType(TextFormField),
          findsNWidgets(2),
        ); // email + password
        expect(find.text('Masuk'), findsOneWidget);
      });

      testWidgets('Email validation shows error for empty email', (
        WidgetTester tester,
      ) async {
        Get.reset();
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        Get.offAllNamed(AppRoutes.login);
        await tester.pumpAndSettle();

        final auth = Get.find<AuthController>();
        auth.emailController.clear();
        auth.passwordController.clear();

        await tester.tap(find.text('Masuk'));
        await tester.pump();

        expect(auth.emailError.value, 'Email tidak boleh kosong');
      });

      testWidgets('Password visibility toggle works', (
        WidgetTester tester,
      ) async {
        Get.reset();
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        Get.offAllNamed(AppRoutes.login);
        await tester.pumpAndSettle();

        final auth = Get.find<AuthController>();
        expect(auth.obscurePassword.value, true);

        final visibilityIcon = find.byIcon(Icons.visibility_off_outlined);
        expect(visibilityIcon, findsOneWidget);
        await tester.tap(visibilityIcon);
        await tester.pump();

        expect(auth.obscurePassword.value, false);
      });
    });

    group('Register View Tests', () {
      testWidgets('Register view displays all fields', (
        WidgetTester tester,
      ) async {
        Get.reset();
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        Get.offAllNamed(AppRoutes.register);
        await tester.pumpAndSettle();

        expect(find.text('Buat Akun Baru'), findsOneWidget);
        expect(
          find.byType(TextFormField),
          findsNWidgets(4),
        ); // name, email, password, confirm
        expect(find.text('Buat Akun'), findsOneWidget);
      });

      testWidgets('Terms agreement required for registration', (
        WidgetTester tester,
      ) async {
        Get.reset();
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        Get.offAllNamed(AppRoutes.register);
        await tester.pumpAndSettle();

        final auth = Get.find<AuthController>();
        auth.nameController.text = 'John Doe';
        auth.emailController.text = 'john@example.com';
        auth.passwordController.text = 'password123';
        auth.confirmController.text = 'password123';
        auth.agreedToTerms.value = false;
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Buat Akun'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Buat Akun'));
        await tester.pumpAndSettle();

        expect(find.text('Persetujuan Diperlukan'), findsOneWidget);
        Get.closeAllSnackbars();
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
      });

      testWidgets('Password mismatch shows error', (WidgetTester tester) async {
        Get.reset();
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        Get.offAllNamed(AppRoutes.register);
        await tester.pumpAndSettle();

        final auth = Get.find<AuthController>();
        auth.nameController.text = 'John Doe';
        auth.emailController.text = 'john@example.com';
        auth.passwordController.text = 'password123';
        auth.confirmController.text = 'differentpassword';
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Buat Akun'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Buat Akun'));
        await tester.pumpAndSettle();

        expect(auth.confirmError.value, 'Password tidak cocok');
      });
    });

    group('Symptom View Tests', () {
      testWidgets('Symptom view displays symptom list', (
        WidgetTester tester,
      ) async {
        Get.reset();
        Get.lazyPut<SymptomController>(() => SymptomController(), fenix: true);
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        Get.offAllNamed(AppRoutes.symptom);
        await tester.pumpAndSettle();

        expect(find.text('Cek gejala'), findsOneWidget);
        expect(find.text('Demam'), findsOneWidget);
        expect(find.text('Sakit Kepala'), findsOneWidget);
      });

      testWidgets('Search filters symptoms correctly', (
        WidgetTester tester,
      ) async {
        Get.reset();
        Get.lazyPut<SymptomController>(() => SymptomController(), fenix: true);
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        Get.offAllNamed(AppRoutes.symptom);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'demam');
        await tester.pumpAndSettle();

        expect(find.text('Demam'), findsOneWidget);
        expect(find.text('Sakit Kepala'), findsNothing);
      });

      testWidgets('Selecting symptoms updates count', (
        WidgetTester tester,
      ) async {
        Get.reset();
        Get.lazyPut<SymptomController>(() => SymptomController(), fenix: true);
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        Get.offAllNamed(AppRoutes.symptom);
        await tester.pumpAndSettle();

        final controller = Get.find<SymptomController>();
        expect(controller.symptoms.length, 0);

        await tester.tap(find.text('Demam').first);
        await tester.pumpAndSettle();

        expect(controller.symptoms.length, 1);
      });
    });
  });
}
