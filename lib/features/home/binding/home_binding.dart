import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../controller/disease_news_controller.dart';
import '../../symptom/controller/symptom_controller.dart';
import '../../scan/controller/scan_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../../core/api/api_provider.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // API Provider (singleton)
    if (!Get.isRegistered<ApiProvider>()) {
      Get.put(ApiProvider(), permanent: true);
    }

    // Home Tab
    Get.lazyPut<HomeController>(() => HomeController());

    // Disease News
    Get.lazyPut<DiseaseNewsController>(() => DiseaseNewsController(), fenix: true);

    // Symptom Tab
    Get.lazyPut<SymptomController>(() => SymptomController(), fenix: true);

    // Scan Tab
    Get.lazyPut<ScanController>(() => ScanController(), fenix: true);

    // Profile Tab
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
