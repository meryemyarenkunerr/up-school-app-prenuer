import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:sign_in_with_apple/sign_in_with_apple.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "auth_models.dart";
import "auth_provider.dart";

class AuthRepository {
  AuthRepository({
    required SupabaseClient supabase,
    FlutterSecureStorage? secureStorage,
  })  : _supabase = supabase,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final SupabaseClient _supabase;
  final FlutterSecureStorage _secureStorage;

  Future<AuthSession> signInWithProvider({
    required SocialAuthProvider provider,
    required String deviceHash,
  }) async {
    final idToken = switch (provider) {
      SocialAuthProvider.google => await _googleIdToken(),
      SocialAuthProvider.apple => await _appleIdToken(),
    };

    if (idToken == null || idToken.isEmpty) {
      throw StateError("Failed to acquire provider token.");
    }

    final response = await _supabase.functions.invoke(
      "social-login",
      body: {
          "provider": provider.value,
          "id_token": idToken,
          "device_hash": deviceHash,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError("Missing auth response payload.");
    }

    final session = AuthSession(
      accessToken: data["access_token"] as String,
      refreshToken: data["refresh_token"] as String,
      userId: data["user_id"] as String,
    );

    await _persistSession(session);
    return session;
  }

  Future<UserProfile> fetchMyProfile() async {
    final response = await _supabase.functions.invoke("me");
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError("Profile response is empty.");
    }

    return UserProfile.fromJson(data);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasPersistedSession() async {
    final access = await _secureStorage.read(key: _accessTokenKey);
    final refresh = await _secureStorage.read(key: _refreshTokenKey);
    return access != null && refresh != null;
  }

  Future<String?> _googleIdToken() async {
    final account = await GoogleSignIn(scopes: ["email", "profile"]).signIn();
    final auth = await account?.authentication;
    return auth?.idToken;
  }

  Future<String?> _appleIdToken() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [AppleIDAuthorizationScopes.email],
    );
    return credential.identityToken;
  }

  Future<void> _persistSession(AuthSession session) async {
    await _secureStorage.write(key: _accessTokenKey, value: session.accessToken);
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: session.refreshToken,
    );
  }
}

const String _accessTokenKey = "auth.access_token";
const String _refreshTokenKey = "auth.refresh_token";
