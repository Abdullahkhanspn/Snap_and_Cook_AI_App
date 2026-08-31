import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/profile_service.dart';
import '../models/user_profile_model.dart';
import 'auth_provider.dart';

final profileServiceProvider = Provider<ProfileService>((ref) => FirestoreProfileService());

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfileModel?>>((ref) {
  final authState = ref.watch(authStateProvider);
  final service = ref.watch(profileServiceProvider);
  
  final uid = authState.value?.uid;
  return UserProfileNotifier(service, uid);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfileModel?>> {
  final ProfileService _service;
  final String? _uid;

  UserProfileNotifier(this._service, this._uid) : super(const AsyncValue.loading()) {
    if (_uid != null) {
      loadProfile();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> loadProfile() async {
    if (_uid == null) return;
    state = const AsyncValue.loading();
    try {
      final profile = await _service.getProfile(_uid!);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveProfile(UserProfileModel profile) async {
    state = const AsyncValue.loading();
    try {
      await _service.saveProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
