class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.role,
    this.nationality,
  });

  final String id;
  final String displayName;
  final String avatarUrl;
  final String role;
  final String? nationality;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"] as String,
      displayName: (json["display_name"] as String?) ?? "",
      avatarUrl: (json["avatar_url"] as String?) ?? "",
      role: (json["role"] as String?) ?? "free",
      nationality: json["nationality"] as String?,
    );
  }
}
