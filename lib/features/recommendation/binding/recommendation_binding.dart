import 'package:get/get.dart';
import '../controller/recommendation_controller.dart';

class RecommendationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RecommendationController>()) {
      Get.lazyPut<RecommendationController>(
        () => RecommendationController(),
        fenix: true,
      );
    }
  }
}
