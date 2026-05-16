import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScanController extends GetxController {
  var isScanning = false.obs;
  var scannedResult = ''.obs;

  void scanBarcode() {
    isScanning.value = true;
    // Simulate scanning
    Future.delayed(const Duration(seconds: 2), () {
      try {
        scannedResult.value = 'OBAT-001';
        isScanning.value = false;
        Get.snackbar(
          'Berhasil',
          'Obat terdeteksi: $scannedResult',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 16,
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } catch (e) {
        isScanning.value = false;
        Get.snackbar(
          'Error',
          'Gagal memindai barcode. Silakan coba lagi.',
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 16,
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    });
  }

  void stopScanning() {
    isScanning.value = false;
  }
}
