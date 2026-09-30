import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/api_config.dart';
import 'core/sync/wiring.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_providers.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_shell.dart';

/// Upper bound on the platform text-scale factor.
///
/// Accessibility scaling is a real requirement, but these screens are dense
/// government tables with fixed-height rows and multi-line statutory values.
/// Past roughly 1.5x (Android's "Large" step) the layout stops being a table
/// and starts being clipped text, so the app is capped there and the visual
/// suite renders at exactly this scale to catch anything that does overflow.
///
/// Raise this only alongside a pass over the fixed-height rows.
const double kMaxTextScaleFactor = 1.5;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load();
  runApp(const ProviderScope(child: TerranexApp()));
}

class TerranexApp extends ConsumerStatefulWidget {
  const TerranexApp({super.key});

  @override
  ConsumerState<TerranexApp> createState() => _TerranexAppState();
}

class _TerranexAppState extends ConsumerState<TerranexApp> {
  bool _wired = false;

  @override
  void initState() {
    super.initState();
    // Wire sync after first frame when providers available.
    // `wireDependencies` also starts the connectivity watcher, so this is the
    // only place the bootstrap needs to happen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_wired && mounted) {
        wireDependencies(ProviderScope.containerOf(context, listen: false));
        _wired = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(signedInProvider);
    final theme = buildAppTheme();

    return MaterialApp(
      title: 'Terranex FO',
      debugShowCheckedModeBanner: false,
      theme: theme,
      // Light only, by design: this is a field app used in bright daylight
      // against printed survey documents, and several screens are full-bleed
      // media where a dark chrome would fight the photo.
      darkTheme: theme,
      themeMode: ThemeMode.light,
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final capped = mq.textScaler.clamp(maxScaleFactor: kMaxTextScaleFactor);
        if (capped == mq.textScaler) return child!;
        return MediaQuery(
          data: mq.copyWith(textScaler: capped),
          child: child!,
        );
      },
      // Swapping `home` replaces the first route, so signing out tears the
      // whole stack down — `HomeShell` can no longer be popped back into.
      home: signedIn ? const HomeShell() : const LoginScreen(),
    );
  }
}

/// App-wide scroll behaviour.
///
/// No overscroll travel of any kind: lists stop dead at the top and bottom
/// edge. The previous build ran [BouncingScrollPhysics] app-wide with a spring
/// at 3.6% damping, so every overscroll rang for many oscillations before
/// settling — the app felt like it was fighting the finger. Mouse and trackpad
/// drags stay enabled so the same build behaves sensibly on a tablet.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  /// Clamping kills the rubber band. `AlwaysScrollable` on the outside keeps
  /// pull-to-refresh arming on lists shorter than the viewport.
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics());
}
