
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? profilePictureUrl;
  final String accountNumber;
  final String language;
  final bool isDarkMode;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profilePictureUrl,
    required this.accountNumber,
    required this.language,
    required this.isDarkMode,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      profilePictureUrl: map['profilePictureUrl'] as String?,
      accountNumber: map['accountNumber'] as String? ?? '',
      language: map['language'] as String? ?? 'en',
      isDarkMode: map['isDarkMode'] as bool? ?? false,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'profilePictureUrl': profilePictureUrl,
      'accountNumber': accountNumber,
      'language': language,
      'isDarkMode': isDarkMode,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
