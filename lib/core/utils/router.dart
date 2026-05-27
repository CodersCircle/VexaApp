import 'package:go_router/go_router.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/downloads/ui/downloads_screen.dart';
import '../../features/splash/ui/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/downloads',
      builder: (context, state) => const DownloadsScreen(),
    ),
  ],
);
