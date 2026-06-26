import 'package:get/get.dart';
import '../../../core/api/api_provider.dart';
import '../../auth/controller/auth_controller.dart';

class Message {
  final String content;
  final bool isUser;

  Message({required this.content, required this.isUser});
}

class ChatbotController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final AuthController _authController = Get.find<AuthController>();

  var messages = <Message>[].obs;
  var isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    _addWelcome();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isTyping.value) return;

    messages.add(Message(content: trimmed, isUser: true));
    isTyping.value = true;

    try {
      final response = await _apiProvider.getChatbotResponse(
        _authController.token.value,
        trimmed,
      );

      if (response.status.isOk) {
        final reply = response.body['reply'] ?? 'Maaf, saya tidak mengerti.';
        messages.add(Message(content: reply.toString(), isUser: false));
      } else {
        messages.add(
          Message(
            content: 'Maaf, terjadi gangguan koneksi ke asisten SEHATI.',
            isUser: false,
          ),
        );
      }
    } catch (e) {
      messages.add(
        Message(
          content: 'Koneksi ke server terputus. Silakan coba lagi nanti.',
          isUser: false,
        ),
      );
    } finally {
      isTyping.value = false;
    }
  }

  void clearChat() {
    messages.clear();
    isTyping.value = false;
    _addWelcome();
  }

  void _addWelcome() {
    messages.add(
      Message(
        content:
            'Halo, saya asisten SEHATI. Saya bisa bantu jelaskan gejala ringan, aturan pakai umum, dan kapan sebaiknya konsultasi.',
        isUser: false,
      ),
    );
  }
}
