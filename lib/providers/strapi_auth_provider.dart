import 'package:flutter/material.dart';
import 'package:love_in_action/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/strapi_auth_response.dart';
import '../models/strapi_user.dart';
import '../services/strapi_auth_service.dart';

class StrapiAuthProvider extends ChangeNotifier {
  final StrapiAuthService _service = StrapiAuthService();

  String? _jwt;
  StrapiUser? _user;
  bool _initialized = false;

  String? get jwt => _jwt;
  StrapiUser? get user => _user;
  bool get isAuthenticated => _jwt != null && _jwt!.isNotEmpty;
  bool get initialized => _initialized;

  Future<void> initializeAuth() async {
    try {
      _jwt = await _service.getSavedToken();
    } catch (_) {
      _jwt = null;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> login(String emailOrUsername, String password) async {
    final StrapiAuthResponse auth = await _service.login(
      identifier: emailOrUsername,
      password: password,
    );
    _jwt = auth.jwt;
    _user = auth.user;
    notifyListeners();
  }

  Future<void> getUser() async {
    final user = await _service.getMe();
    _user = user;
    notifyListeners();
  }


  Future<void> register(String email, String password, {required String username}) async {
    final StrapiAuthResponse auth = await _service.register(
      email: email,
      password: password,
      username: username,
    );
    _jwt = auth.jwt;
    _user = auth.user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout();
    _jwt = null;
    _user = null;
    notifyListeners();
  }
}
