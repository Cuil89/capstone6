import 'package:get/get.dart';

class OnboardingController extends GetxController {
  var pageIndex = 0.obs;

  var age = ''.obs;
  var gender = ''.obs;
  var allergies = ''.obs;
  var conditions = ''.obs;

  void nextPage() {
    if (pageIndex.value < 3) {
      pageIndex.value++;
    }
  }

  void previousPage() {
    if (pageIndex.value > 0) {
      pageIndex.value--;
    }
  }

  void setAge(String value) => age.value = value;
  void setGender(String value) => gender.value = value;
  void setAllergies(String value) => allergies.value = value;
  void setConditions(String value) => conditions.value = value;
}
