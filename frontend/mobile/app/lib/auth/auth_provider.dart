enum SocialAuthProvider {
  google,
  apple,
}

extension SocialAuthProviderX on SocialAuthProvider {
  String get value {
    switch (this) {
      case SocialAuthProvider.google:
        return "google";
      case SocialAuthProvider.apple:
        return "apple";
    }
  }
}
