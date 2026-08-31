import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile_model.dart';

abstract class ProfileService {
  Future<UserProfileModel?> getProfile(String uid);
  Future<void> saveProfile(UserProfileModel profile);
  Future<void> createOrUpdateUser(String uid, {String? name, String? email, String? photoUrl, String? provider});
}

class FirestoreProfileService implements ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<UserProfileModel?> getProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      print('Error fetching profile: \$e');
    }
    return null;
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    await _db.collection('users').doc(profile.uid).set(
      {
        ...profile.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> createOrUpdateUser(String uid, {String? name, String? email, String? photoUrl, String? provider}) async {
    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();

    final data = {
      'uid': uid,
      if (name != null) 'fullName': name,
      if (email != null) 'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (provider != null) 'provider': provider,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    if (!doc.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);
    } else {
      await docRef.update(data);
    }
  }
}

class MockProfileService implements ProfileService {
  final Map<String, UserProfileModel> _profiles = {};

  @override
  Future<UserProfileModel?> getProfile(String uid) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _profiles[uid];
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _profiles[profile.uid] = profile;
  }

  @override
  Future<void> createOrUpdateUser(String uid, {String? name, String? email, String? photoUrl, String? provider}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
