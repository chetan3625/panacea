import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_routes.dart';

class AuthSession extends GetxService {
  static const _tokenKey = 'panacea_auth_token';

  final token = RxnString();

  bool get isAuthenticated => token.value?.isNotEmpty == true;

  Future<void> restore() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedToken = preferences.getString(_tokenKey);
      if (savedToken != null && savedToken.isNotEmpty) {
        token.value = savedToken;
      }
    } catch (_) {
      token.value = null;
    }
  }

  Future<void> signIn(String value) async {
    token.value = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, value);
  }

  Future<void> signOut() async {
    token.value = null;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_tokenKey);
    } catch (_) {
      // Keep the in-memory session cleared even if storage is unavailable.
    }
    await Get.offAllNamed(AppRoutes.login);
  }
}
