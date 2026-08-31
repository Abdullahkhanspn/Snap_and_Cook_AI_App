import 'package:cloud_firestore/cloud_firestore.dart';

enum DietaryPreference { vegetarian, vegan, nonVegetarian }

class UserProfileModel {
  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final String? provider;
  final int? age;
  final List<String> allergies;
  final DietaryPreference dietaryPreference;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  UserProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.provider,
    this.age,
    required this.allergies,
    required this.dietaryPreference,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfileModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      provider: map['provider'],
      age: map['age'],
      allergies: List<String>.from(map['allergies'] ?? []),
      dietaryPreference: DietaryPreference.values.firstWhere(
        (e) => e.name == map['dietaryPreference'],
        orElse: () => DietaryPreference.nonVegetarian,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'provider': provider,
      'age': age,
      'allergies': allergies,
      'dietaryPreference': dietaryPreference.name,
      // Timestamps are handled by the service using FieldValue.serverTimestamp()
    };
  }

  UserProfileModel copyWith({
    String? fullName,
    String? email,
    String? photoUrl,
    String? provider,
    int? age,
    List<String>? allergies,
    DietaryPreference? dietaryPreference,
  }) {
    return UserProfileModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      age: age ?? this.age,
      allergies: allergies ?? this.allergies,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }
}
