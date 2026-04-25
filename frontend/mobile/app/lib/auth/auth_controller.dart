import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "../core/device_hash.dart";
import "auth_models.dart";
import "auth_provider.dart";
import "auth_repository.dart";

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(supabase: ref.watch(supabaseClientProvider));
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, bool>(AuthController.new);

class AuthController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repo = ref.read(authRepositoryProvider);
    return repo.hasPersistedSession();
  }

  Future<void> signIn({
    required SocialAuthProvider provider,
    required String rawDeviceId,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final deviceHash = generateDeviceHash(
        rawDeviceId: rawDeviceId,
        appSalt: "eurovision-fan-app",
      );
      await repo.signInWithProvider(provider: provider, deviceHash: deviceHash);
      return true;
    });
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncData(false);
  }

  Future<UserProfile> loadProfile() {
    return ref.read(authRepositoryProvider).fetchMyProfile();
  }
}
