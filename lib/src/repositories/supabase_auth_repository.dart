import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _userCacheKey = 'cached_user';
  AppUser? _cachedUser;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  AppUser? get localUser => _cachedUser;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userCacheKey);
    if (userJson != null) {
      try {
        _cachedUser = AppUser.fromJson(jsonDecode(userJson));
      } catch (e) {
        debugPrint("Error decoding cached user: $e");
      }
    }
  }

  Future<void> _cacheUser(AppUser user) async {
    _cachedUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userCacheKey, jsonEncode(user.toJson()));
  }

  @override
  Future<AuthResponse> loginWithEmail(String email, String password) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    if (response.user != null) {
      await _fetchAndCacheProfile(response.user!.id);
    }
    return response;
  }

  @override
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> loginWithPhone(String phone) async {
    return await _client.auth.signInWithOtp(phone: phone);
  }

  @override
  Future<AuthResponse> verifyOtp(String phone, String token) async {
    final response = await _client.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);
    if (response.user != null) {
      await _fetchAndCacheProfile(response.user!.id);
    }
    return response;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
    _cachedUser = null;
    return await _client.auth.signOut();
  }

  @override
  Future<void> updateProfile({required String name, String? avatarUrl}) async {
    final user = currentUser;
    if (user == null) return;

    await _client.from('profiles').upsert({'id': user.id, 'name': name, 'avatar_url': avatarUrl});

    final appUser = AppUser(id: user.id, name: name, avatarUrl: avatarUrl ?? '');
    await _cacheUser(appUser);
  }

  Future<void> _fetchAndCacheProfile(String userId) async {
    try {
      final response = await _client.from('profiles').select().eq('id', userId).maybeSingle();
      if (response != null) {
        final appUser = AppUser(id: response['id'], name: response['name'], avatarUrl: response['avatar_url'] ?? '');
        await _cacheUser(appUser);
      }
    } catch (e) {
      debugPrint("Error fetching profile to cache: $e");
    }
  }
}
