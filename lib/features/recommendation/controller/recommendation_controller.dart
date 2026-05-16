import 'package:get/get.dart';

class RecommendationController extends GetxController {
  var results = <Map<String, dynamic>>[].obs;

  void generateRecommendation(List<String> symptoms) {
    results.clear();
    if (symptoms.isEmpty) return;

    final rules = [
      {
        'name': 'Paracetamol',
        'type': 'Tablet generik',
        'symptoms': ['Demam', 'Sakit Kepala', 'Nyeri Otot'],
        'desc': 'Meredakan demam dan nyeri ringan hingga sedang.',
        'indication': 'Demam, sakit kepala, nyeri otot',
        'dose':
            'Ikuti aturan pakai pada kemasan atau anjuran tenaga kesehatan.',
        'side_effect':
            'Mual atau reaksi alergi dapat terjadi pada sebagian orang.',
        'warning':
            'Hindari penggunaan berlebihan, terutama bila ada gangguan hati.',
      },
      {
        'name': 'OBH Combi',
        'type': 'Sirup batuk',
        'symptoms': ['Batuk', 'Sakit Tenggorokan'],
        'desc':
            'Membantu meredakan batuk dan rasa tidak nyaman di tenggorokan.',
        'indication': 'Batuk dan tenggorokan tidak nyaman',
        'dose': 'Gunakan sesuai takaran usia pada label obat.',
        'side_effect': 'Dapat menyebabkan kantuk pada beberapa varian.',
        'warning': 'Hindari berkendara jika muncul rasa mengantuk.',
      },
      {
        'name': 'Decolgen',
        'type': 'Tablet flu',
        'symptoms': ['Pilek', 'Demam', 'Sakit Kepala'],
        'desc': 'Membantu meredakan gejala flu seperti pilek dan demam.',
        'indication': 'Pilek, demam, sakit kepala',
        'dose':
            'Gunakan sesuai petunjuk kemasan dan jangan digabung sembarangan.',
        'side_effect': 'Mengantuk, mulut kering, atau jantung berdebar.',
        'warning': 'Perlu perhatian khusus bila memiliki hipertensi.',
      },
      {
        'name': 'Oralit',
        'type': 'Serbuk rehidrasi',
        'symptoms': ['Diare', 'Mual'],
        'desc': 'Membantu mengganti cairan dan elektrolit saat diare.',
        'indication': 'Diare ringan dan risiko dehidrasi',
        'dose': 'Larutkan sesuai petunjuk kemasan dengan air matang.',
        'side_effect': 'Umumnya ringan bila digunakan sesuai petunjuk.',
        'warning': 'Segera cari bantuan medis bila diare berat atau berdarah.',
      },
      {
        'name': 'Cetirizine',
        'type': 'Antihistamin',
        'symptoms': ['Alergi Kulit', 'Gatal-gatal', 'Pilek'],
        'desc': 'Membantu meredakan gejala alergi seperti gatal dan bersin.',
        'indication': 'Alergi kulit, gatal, bersin alergi',
        'dose': 'Gunakan sesuai anjuran pada kemasan atau resep.',
        'side_effect': 'Dapat menimbulkan kantuk atau mulut kering.',
        'warning': 'Hindari aktivitas yang butuh konsentrasi bila mengantuk.',
      },
    ];

    for (final rule in rules) {
      final ruleSymptoms = rule['symptoms']! as List<String>;
      final matches = ruleSymptoms
          .where((symptom) => symptoms.contains(symptom))
          .toList();
      if (matches.isEmpty) continue;

      final score = matches.length / ruleSymptoms.length;
      results.add({
        ...rule,
        'score': score,
        'matched': matches.length,
        'matchedSymptoms': matches,
        'reason': 'Cocok dengan ${matches.join(', ')}',
      });
    }

    results.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );
  }
}
