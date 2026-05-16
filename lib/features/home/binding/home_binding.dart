import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../controller/disease_news_controller.dart';
import '../../symptom/controller/symptom_controller.dart';
import '../../scan/controller/scan_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../recommendation/controller/recommendation_controller.dart';
import '../../../core/api/api_provider.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // API Provider (singleton)
    if (!Get.isRegistered<ApiProvider>()) {
      Get.put(ApiProvider(), permanent: true);
    }

    // Home Tab
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController());
    }

    // Disease News
    if (!Get.isRegistered<DiseaseNewsController>()) {
      Get.lazyPut<DiseaseNewsController>(
        () => DiseaseNewsController(),
        fenix: true,
      );
    }

    // Symptom Tab
    if (!Get.isRegistered<SymptomController>()) {
      Get.lazyPut<SymptomController>(() => SymptomController(), fenix: true);
    }

    // Recommendation result, dibutuhkan dari SymptomView yang berada di tab.
    if (!Get.isRegistered<RecommendationController>()) {
      Get.lazyPut<RecommendationController>(
        () => RecommendationController(),
        fenix: true,
      );
    }

    // Scan Tab
    if (!Get.isRegistered<ScanController>()) {
      Get.lazyPut<ScanController>(() => ScanController(), fenix: true);
    }

    // Profile Tab
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    }
  }
}
