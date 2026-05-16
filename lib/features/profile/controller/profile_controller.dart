import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_provider.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  ApiProvider get _apiProvider => Get.find<ApiProvider>();
  AuthController get _authController => Get.find<AuthController>();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final name = ''.obs;
  final email = ''.obs;
  final profilePictureUrl = ''.obs;

  Map<String, dynamic> _body(Response response) =>
      ApiProvider.bodyAsMap(response);

  String _message(
    Response response, {
    String fallback = 'Terjadi kesalahan. Silakan coba lagi.',
  }) {
    return ApiProvider.messageFromResponse(response, fallback: fallback);
  }

  void syncFromAuth() {
    final user = _authController.userData;
    name.value = user['name']?.toString() ?? '';
    email.value = user['email']?.toString() ?? '';
    profilePictureUrl.value = user['profile_picture_url']?.toString() ?? '';
  }

  void _syncUser(Map<String, dynamic> user) {
    final merged = <String, dynamic>{
      ...Map<String, dynamic>.from(_authController.userData),
      ...user,
    };
    _authController.userData.value = merged;
    syncFromAuth();
  }

  Future<bool> loadProfile({bool silent = false}) async {
    if (_authController.token.value.isEmpty) return false;
    if (!silent) isLoading.value = true;
    try {
      final response = await _apiProvider.getProfile(
        _authController.token.value,
      );
      final body = _body(response);
      if (response.status.isOk) {
        _syncUser(body);
        return true;
      }
      if (!silent) {
        Get.snackbar(
          'Profil Gagal Dimuat',
          _message(response, fallback: 'Gagal memuat profil.'),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    } catch (_) {
      if (!silent) {
        Get.snackbar(
          'Koneksi Bermasalah',
          'Server tidak dapat dihubungi. Pastikan backend berjalan.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<bool> saveProfile({required String name, XFile? photo}) async {
    if (_authController.token.value.isEmpty) return false;
    isSaving.value = true;
    try {
      final trimmedName = name.trim();
      final response = await _apiProvider.updateProfile(
        _authController.token.value,
        name: trimmedName,
      );
      final body = _body(response);
      if (!response.status.isOk) {
        Get.snackbar(
          'Profil Gagal Disimpan',
          _message(response, fallback: 'Gagal menyimpan profil.'),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (body['user'] is Map) {
        _syncUser(Map<String, dynamic>.from(body['user']));
      }

      if (photo != null) {
        final photoSaved = await uploadProfilePhoto(photo);
        if (!photoSaved) return false;
      }

      Get.snackbar(
        'Profil Diperbarui',
        'Data profil Anda berhasil disimpan.',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (_) {
      Get.snackbar(
        'Koneksi Bermasalah',
        'Server tidak dapat dihubungi. Pastikan backend berjalan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> uploadProfilePhoto(XFile photo) async {
    final bytes = await photo.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024) {
      Get.snackbar(
        'Foto Terlalu Besar',
        'Ukuran foto maksimal 2 MB.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final response = await _apiProvider.uploadProfilePhoto(
      token: _authController.token.value,
      bytes: bytes,
      filename: _normalizedFilename(photo.name),
      contentType: _contentType(photo.name),
    );
    final body = _body(response);
    if (!response.status.isOk) {
      Get.snackbar(
        'Foto Gagal Diunggah',
        _message(response, fallback: 'Gagal mengunggah foto profil.'),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (body['user'] is Map) {
      _syncUser(Map<String, dynamic>.from(body['user']));
    }
    return true;
  }

  Future<bool> deleteProfilePhoto() async {
    if (_authController.token.value.isEmpty) return false;
    isSaving.value = true;
    try {
      final response = await _apiProvider.deleteProfilePhoto(
        _authController.token.value,
      );
      final body = _body(response);
      if (!response.status.isOk) {
        Get.snackbar(
          'Foto Gagal Dihapus',
          _message(response, fallback: 'Gagal menghapus foto profil.'),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (body['user'] is Map) {
        _syncUser(Map<String, dynamic>.from(body['user']));
      }
      Get.snackbar(
        'Foto Dihapus',
        'Foto profil Anda berhasil dihapus.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (_) {
      Get.snackbar(
        'Koneksi Bermasalah',
        'Server tidak dapat dihubungi. Pastikan backend berjalan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  String _normalizedFilename(String original) {
    final fallback = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final value = original.trim().isEmpty ? fallback : original.trim();
    return value.replaceAll(RegExp(r'\s+'), '_');
  }

  String _contentType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
