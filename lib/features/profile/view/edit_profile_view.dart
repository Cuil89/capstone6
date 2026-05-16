import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/profile_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;

  ProfileController get _profileController => Get.find<ProfileController>();
  AuthController get _authController => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _syncNameFromAuth();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _profileController.loadProfile(silent: true);
      if (mounted) _syncNameFromAuth();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncNameFromAuth() {
    _profileController.syncFromAuth();
    _nameController.text = _authController.userData['name']?.toString() ?? '';
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (photo == null) return;

    final bytes = await photo.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024) {
      Get.snackbar(
        'Foto Terlalu Besar',
        'Ukuran foto maksimal 2 MB.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _selectedPhoto = photo;
      _selectedPhotoBytes = bytes;
    });
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await _profileController.saveProfile(
      name: _nameController.text,
      photo: _selectedPhoto,
    );
    if (!mounted || !success) return;
    setState(() {
      _selectedPhoto = null;
      _selectedPhotoBytes = null;
    });
    Get.back(result: true);
  }

  Future<void> _deletePhoto() async {
    final success = await _profileController.deleteProfilePhoto();
    if (!mounted || !success) return;
    setState(() {
      _selectedPhoto = null;
      _selectedPhotoBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final user = _authController.userData;
          final email = user['email']?.toString() ?? '';
          final isVerified = user['is_verified'] == true;
          final hasPhoto =
              (_selectedPhotoBytes != null) ||
              ((user['profile_picture_url']?.toString() ?? '').isNotEmpty);
          final loading = _profileController.isSaving.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAvatarSection(
                    isVerified: isVerified,
                    hasPhoto: hasPhoto,
                    loading: loading,
                  ),
                  const SizedBox(height: 22),
                  _buildIdentityForm(email: email, isVerified: isVerified),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: loading ? null : _saveProfile,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(loading ? 'Menyimpan' : 'Simpan Perubahan'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: loading ? null : () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Batalkan'),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAvatarSection({
    required bool isVerified,
    required bool hasPhoto,
    required bool loading,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _buildAvatar(size: 118),
              Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: loading ? null : _pickPhoto,
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _authController.userData['name']?.toString() ?? 'User',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildVerificationBadge(isVerified),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: loading ? null : _pickPhoto,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Pilih Foto'),
                ),
              ),
              if (hasPhoto) ...[
                const SizedBox(width: 10),
                SizedBox(
                  width: 54,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: loading ? null : _deletePhoto,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColors.error,
                      minimumSize: const Size(54, 54),
                      fixedSize: const Size(54, 54),
                    ),
                    child: const Icon(Icons.delete_outline_rounded),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityForm({required String email, required bool isVerified}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Data Akun',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            maxLength: 100,
            decoration: const InputDecoration(
              counterText: '',
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return 'Nama lengkap wajib diisi';
              if (name.length > 100) return 'Nama maksimal 100 karakter';
              return null;
            },
            onFieldSubmitted: (_) => _saveProfile(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            initialValue: email,
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: Icon(
                isVerified
                    ? Icons.verified_rounded
                    : Icons.warning_amber_rounded,
                color: isVerified ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required double size}) {
    final image = _selectedPhotoBytes;
    final remoteUrl = ApiConfig.absoluteUrl(
      _authController.userData['profile_picture_url']?.toString() ?? '',
    );
    final name = _authController.userData['name']?.toString() ?? 'User';

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLighter,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: AppTheme.softShadow,
      ),
      child: image != null
          ? Image.memory(image, fit: BoxFit.cover)
          : (remoteUrl.isNotEmpty
                ? Image.network(
                    remoteUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitials(name),
                  )
                : _buildInitials(name)),
    );
  }

  Widget _buildInitials(String name) {
    return Center(
      child: Text(
        _initials(name),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(bool isVerified) {
    final color = isVerified ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.warning_amber_rounded,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            isVerified ? 'Akun terverifikasi' : 'Belum terverifikasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'SF';
    final first = parts.first[0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }
}
