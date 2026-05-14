import 'package:get/get.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../api/api_provider.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiProvider(), permanent: true);

    // State auth dipakai lintas login/register/OTP, jadi jangan ikut dispose route.
    Get.put(AuthController(), permanent: true);
  }
}
