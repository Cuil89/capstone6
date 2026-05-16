import 'package:get/get.dart';
import '../../recommendation/controller/recommendation_controller.dart';
import '../controller/symptom_controller.dart';

class SymptomBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SymptomController>()) {
      Get.lazyPut<SymptomController>(() => SymptomController(), fenix: true);
    }
    if (!Get.isRegistered<RecommendationController>()) {
      Get.lazyPut<RecommendationController>(
        () => RecommendationController(),
        fenix: true,
      );
    }
  }
}
