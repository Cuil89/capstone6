import 'package:get/get.dart';
import '../../../data/models/disease_news_model.dart';
import '../../../core/api/api_provider.dart';

class DiseaseNewsController extends GetxController {
  final ApiProvider _api = Get.find<ApiProvider>();

  // ── State ──────────────────────────────────
  final RxList<DiseaseNewsModel> trendingNews = <DiseaseNewsModel>[].obs;
  final RxList<DiseaseNewsModel> allNews      = <DiseaseNewsModel>[].obs;

  final RxBool  isLoadingTrending = false.obs;
  final RxBool  isLoadingAll      = false.obs;
  final RxBool  hasError          = false.obs;
  final RxString errorMessage     = ''.obs;
  final RxString lastUpdated      = ''.obs;

  // ── Filter & pagination for list page ──────
  final RxString searchQuery    = ''.obs;
  final RxString filterSource   = ''.obs;
  final RxString filterLevel    = ''.obs;
  final RxString filterCountry  = ''.obs;
  final RxString filterRegion   = ''.obs;
  final RxString sortBy         = 'latest'.obs;
  final RxInt    currentPage    = 1.obs;
  final RxInt    totalPages     = 1.obs;
  final RxBool   hasMore        = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrending();
  }

  // ─────────────────────────────────────────────
  // FETCH TRENDING (for Home widget)
  // ─────────────────────────────────────────────
  Future<void> fetchTrending({bool silent = false}) async {
    if (!silent) isLoadingTrending.value = true;
    hasError.value = false;

    try {
      final response = await _api.get('/api/disease-news/trending');
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List data = response.body['data'] ?? [];
        trendingNews.value =
            data.map((e) => DiseaseNewsModel.fromJson(e)).toList();
        final lu = response.body['last_updated'];
        if (lu != null) {
          final dt = DateTime.tryParse(lu);
          if (dt != null) {
            lastUpdated.value =
                'Update: ${dt.day}/${dt.month}/${dt.year}';
          }
        }
      } else {
        _setError('Gagal memuat berita. Coba lagi.');
      }
    } catch (e) {
      _setError('Tidak dapat terhubung ke server.');
    } finally {
      isLoadingTrending.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // FETCH ALL NEWS (for list/detail page)
  // ─────────────────────────────────────────────
  Future<void> fetchAll({bool reset = true}) async {
    if (reset) {
      currentPage.value = 1;
      allNews.clear();
    }
    isLoadingAll.value = true;

    try {
      final response = await _api.getDiseaseNewsList(
        page: currentPage.value,
        perPage: 10,
        sort: sortBy.value,
        search: searchQuery.value,
        source: filterSource.value,
        alertLevel: filterLevel.value,
        country: filterCountry.value,
        region: filterRegion.value,
      );
      if (response.statusCode == 200 && response.body['success'] == true) {
        final List data = response.body['data'] ?? [];
        final pagination = response.body['pagination'] ?? {};
        final items = data.map((e) => DiseaseNewsModel.fromJson(e)).toList();

        if (reset) {
          allNews.value = items;
        } else {
          allNews.addAll(items);
        }
        totalPages.value = pagination['pages'] ?? 1;
        hasMore.value    = pagination['has_next'] ?? false;
      }
    } catch (e) {
      _setError('Gagal memuat daftar berita.');
    } finally {
      isLoadingAll.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingAll.value) return;
    currentPage.value++;
    await fetchAll(reset: false);
  }

  // ─────────────────────────────────────────────
  // FILTER HELPERS
  // ─────────────────────────────────────────────
  void applySearch(String q) {
    searchQuery.value = q;
    fetchAll();
  }

  void applyFilter({String? source, String? level, String? country, String? region, String? sort}) {
    if (source != null) filterSource.value = source;
    if (level != null) filterLevel.value = level;
    if (country != null) filterCountry.value = country;
    if (region != null) filterRegion.value = region;
    if (sort != null) sortBy.value = sort;
    fetchAll();
  }

  void clearFilters() {
    searchQuery.value   = '';
    filterSource.value  = '';
    filterLevel.value   = '';
    filterCountry.value = '';
    filterRegion.value  = '';
    sortBy.value        = 'latest';
    fetchAll();
  }

  // ─────────────────────────────────────────────
  // MANUAL REFRESH
  // ─────────────────────────────────────────────
  Future<void> triggerRefresh() async {
    try {
      await _api.post('/api/disease-news/refresh', {});
    } catch (_) {}
    await fetchTrending();
  }

  void _setError(String msg) {
    hasError.value    = true;
    errorMessage.value = msg;
  }
}
