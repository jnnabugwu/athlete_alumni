import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_constants.dart';

// Import your screens here
import 'package:athlete_alumni/features/home/presentation/pages/home_page.dart';    
import 'package:athlete_alumni/features/auth/presentation/pages/login_page.dart';
import 'package:athlete_alumni/features/auth/presentation/pages/register_page.dart';
import 'package:athlete_alumni/features/profile/presentation/pages/profile_page.dart';
import 'package:athlete_alumni/features/athletes/presentation/pages/athletes_page.dart';
import 'package:athlete_alumni/features/athletes/presentation/pages/athlete_detail_page.dart';

class AppRouter {
  GoRouter get router => _router;

  final _router = GoRouter(
    initialLocation: RouteConstants.home,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: RouteConstants.register,
        name: 'register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      // GoRoute(
      //   path: RouteConstants.profile,
      //   name: 'profile',
      //   pageBuilder: (context, state) => CustomTransitionPage(
      //     key: state.pageKey,
      //     child: const ProfilePage(),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       return FadeTransition(opacity: animation, child: child);
      //     },
      //   ),
      // ),
      // GoRoute(
      //   path: RouteConstants.athletes,
      //   name: 'athletes',
      //   pageBuilder: (context, state) => CustomTransitionPage(
      //     key: state.pageKey,
      //     child: const AthletesPage(),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       return FadeTransition(opacity: animation, child: child);
      //     },
      //   ),
      // ),
      // GoRoute(
      //   path: '${RouteConstants.athletes}/:id',
      //   name: 'athleteDetail',
      //   pageBuilder: (context, state) {
      //     final athleteId = state.pathParameters['id']!;
      //     return CustomTransitionPage(
      //       key: state.pageKey,
      //       child: AthleteDetailPage(athleteId: athleteId),
      //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //         return FadeTransition(opacity: animation, child: child);
      //       },
      //     );
      //   },
      // ),
      // GoRoute(
      //   path: RouteConstants.forums,
      //   name: 'forums',
      //   pageBuilder: (context, state) => CustomTransitionPage(
      //     key: state.pageKey,
      //     child: const ForumsPage(),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       return FadeTransition(opacity: animation, child: child);
      //     },
      //   ),
      // ),
    ],
    errorPageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Text('Error: Page ${state.uri.path} not found'),
        ),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}