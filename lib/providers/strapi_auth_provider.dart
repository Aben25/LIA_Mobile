import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
      // If we have a token, try to fetch user data
      if (_jwt != null && _jwt!.isNotEmpty) {
        try {
          _user = await _service.getMe();
        } catch (e) {
          // If token is invalid, clear it
          debugPrint('❌ [STRAPI AUTH] Invalid token during init: $e');
          _jwt = null;
          _user = null;
        }
      }
    } catch (_) {
      _jwt = null;
      _user = null;
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

  Future<void> register(String email, String password,
      {required String username}) async {
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

  // Password Management
  Future<void> forgotPassword(String email) async {
    await _service.forgotPassword(email);
  }

  Future<void> resetPassword({
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _service.resetPassword(
      code: code,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _service.changePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  // Email Confirmation
  Future<void> confirmEmail(String confirmationToken) async {
    await _service.confirmEmail(confirmationToken);
  }

  Future<void> sendEmailConfirmation(String email) async {
    await _service.sendEmailConfirmation(email);
  }

  // User Management
  Future<void> updateUser(Map<String, dynamic> updates) async {
    if (_user == null) {
      throw Exception('No user logged in');
    }
    final updatedUser = await _service.updateUser(_user!.id, updates);
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_user == null) {
      throw Exception('No user logged in');
    }
    await _service.deleteUser(_user!.id);
    _jwt = null;
    _user = null;
    notifyListeners();
  }
}
