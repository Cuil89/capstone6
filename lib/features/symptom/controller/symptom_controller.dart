import 'package:get/get.dart';

class SymptomController extends GetxController {
  var symptoms = <String>[].obs;

  void toggleSymptom(String symptom) {
    if (symptoms.contains(symptom)) {
      symptoms.remove(symptom);
    } else {
      symptoms.add(symptom);
    }
  }
}
