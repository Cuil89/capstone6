import 'package:get/get.dart';

import '../controller/pharmacy_controller.dart';

class PharmacyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PharmacyController>(() => PharmacyController());
  }
}
