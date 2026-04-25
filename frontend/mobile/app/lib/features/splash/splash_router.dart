import "package:flutter/widgets.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../auth/auth_controller.dart";

class SplashRouter extends ConsumerWidget {
  const SplashRouter({
    required this.homeBuilder,
    required this.signInBuilder,
    super.key,
  });

  final WidgetBuilder homeBuilder;
  final WidgetBuilder signInBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (hasSession) => hasSession ? homeBuilder(context) : signInBuilder(context),
      loading: () => const Center(child: SizedBox.square(dimension: 24)),
      error: (_, __) => signInBuilder(context),
    );
  }
}
