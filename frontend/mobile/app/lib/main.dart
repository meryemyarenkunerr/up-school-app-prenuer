import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "features/splash/splash_router.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment("SUPABASE_URL"),
    anonKey: const String.fromEnvironment("SUPABASE_ANON_KEY"),
  );

  runApp(const ProviderScope(child: EurovisionApp()));
}

class EurovisionApp extends StatelessWidget {
  const EurovisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashRouter(
        homeBuilder: (_) => const _HomePlaceholder(),
        signInBuilder: (_) => const _SignInPlaceholder(),
      ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Home")),
    );
  }
}

class _SignInPlaceholder extends StatelessWidget {
  const _SignInPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Sign in")),
    );
  }
}
