import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

enum PharmacyState {
  initial,
  requestingPermission,
  permissionDenied,
  permissionPermanentlyDenied,
  locationDisabled,
  loading,
  loaded,
  error,
}

class NearbyPharmacy {
  final String name;
  final String address;
  final String distance;
  final bool? isOpen;
  final double? rating;
  final double lat;
  final double lng;

  const NearbyPharmacy({
    required this.name,
    required this.address,
    required this.distance,
    this.isOpen,
    this.rating,
    required this.lat,
    required this.lng,
  });
}

class PharmacyController extends GetxController {
  final _state = PharmacyState.initial.obs;
  final _currentPosition = Rxn<Position>();
  final _pharmacies = <NearbyPharmacy>[].obs;
  final _errorMessage = ''.obs;

  PharmacyState get state => _state.value;
  Position? get currentPosition => _currentPosition.value;
  List<NearbyPharmacy> get pharmacies => _pharmacies;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    initLocation();
  }

  Future<void> initLocation() async {
    _state.value = PharmacyState.requestingPermission;
    _pharmacies.clear();
    _errorMessage.value = '';

    // Cek apakah layanan lokasi aktif
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _state.value = PharmacyState.locationDisabled;
      return;
    }

    // Cek & minta izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _state.value = PharmacyState.permissionDenied;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _state.value = PharmacyState.permissionPermanentlyDenied;
      return;
    }

    // Ambil posisi user
    _state.value = PharmacyState.loading;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _currentPosition.value = position;
      await _loadNearbyPharmacies(position);
    } catch (e) {
      _errorMessage.value = 'Gagal mendapatkan lokasi: ${e.toString()}';
      _state.value = PharmacyState.error;
    }
  }

  Future<void> _loadNearbyPharmacies(Position position) async {
    // Gunakan Google Maps dengan query apotek terdekat
    // Karena tidak ada Places API key, kita buka Google Maps langsung
    // Pharmacies list akan ditampilkan via Google Maps
    _pharmacies.value = _buildDemoPharmacies(position);
    _state.value = PharmacyState.loaded;
  }

  /// Buat data apotek demo berbasis koordinat user.
  /// Pada produksi, ganti dengan Places API response.
  List<NearbyPharmacy> _buildDemoPharmacies(Position pos) {
    return [
      NearbyPharmacy(
        name: 'Apotek Kimia Farma',
        address: 'Jl. Sudirman No.12',
        distance: '0.3 km',
        isOpen: true,
        rating: 4.5,
        lat: pos.latitude + 0.002,
        lng: pos.longitude + 0.001,
      ),
      NearbyPharmacy(
        name: 'Apotek K-24',
        address: 'Jl. Gatot Subroto No.45',
        distance: '0.7 km',
        isOpen: true,
        rating: 4.3,
        lat: pos.latitude - 0.003,
        lng: pos.longitude + 0.004,
      ),
      NearbyPharmacy(
        name: 'Apotek Guardian',
        address: 'Jl. Ahmad Yani No.88',
        distance: '1.1 km',
        isOpen: false,
        rating: 4.1,
        lat: pos.latitude + 0.005,
        lng: pos.longitude - 0.003,
      ),
      NearbyPharmacy(
        name: 'Apotek Century',
        address: 'Jl. Diponegoro No.21',
        distance: '1.4 km',
        isOpen: true,
        rating: 4.7,
        lat: pos.latitude - 0.006,
        lng: pos.longitude - 0.005,
      ),
      NearbyPharmacy(
        name: 'Apotek Indomaret',
        address: 'Jl. Mangga Besar No.77',
        distance: '1.8 km',
        isOpen: true,
        rating: 4.0,
        lat: pos.latitude + 0.008,
        lng: pos.longitude + 0.007,
      ),
    ];
  }

  /// Buka rute ke apotek di Google Maps
  Future<void> openRoute(NearbyPharmacy pharmacy) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${pharmacy.lat},${pharmacy.lng}'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Tidak dapat membuka Maps',
        'Pastikan Google Maps sudah terinstal di perangkat Anda.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }

  /// Buka Google Maps dengan pencarian "apotek terdekat" dari koordinat user
  Future<void> searchAllOnMaps() async {
    final pos = _currentPosition.value;
    Uri uri;
    if (pos != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/apotek+terdekat/'
        '@${pos.latitude},${pos.longitude},15z',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/apotek+terdekat/',
      );
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Buka pengaturan izin aplikasi
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Buka pengaturan lokasi perangkat
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Format koordinat menjadi string ringkas
  String get locationLabel {
    final pos = _currentPosition.value;
    if (pos == null) return 'Lokasi tidak tersedia';
    final lat = pos.latitude.toStringAsFixed(4);
    final lng = pos.longitude.toStringAsFixed(4);
    return '$lat, $lng';
  }
}
