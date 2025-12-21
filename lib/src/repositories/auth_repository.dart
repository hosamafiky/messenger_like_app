import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

abstract class AuthRepository {
  User? get currentUser;
  AppUser? get localUser;
  Stream<AuthState> get authStateChanges;

  Future<void> initialize();
  Future<AuthResponse> loginWithEmail(String email, String password);
  Future<AuthResponse> signUpWithEmail(String email, String password);
  Future<void> loginWithPhone(String phone);
  Future<AuthResponse> verifyOtp(String phone, String token);
  Future<void> signOut();
  Future<void> updateProfile({required String name, String? avatarUrl});
}
