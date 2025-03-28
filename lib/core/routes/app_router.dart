import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:athlete_alumni/core/di/injection.dart';
import 'package:athlete_alumni/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:athlete_alumni/core/routes/route_constants.dart';

// Import your screens here
// import 'package:athlete_alumni/features/profile/presentation/pages/profile_page.dart';
// import 'package:athlete_alumni/features/athletes/presentation/pages/athletes_page.dart';
// import 'package:athlete_alumni/features/athletes/presentation/pages/athlete_detail_page.dart';
import 'package:athlete_alumni/features/auth/presentation/pages/login_page.dart';
import 'package:athlete_alumni/features/auth/presentation/pages/register_page.dart';
import 'package:athlete_alumni/features/home/presentation/pages/home_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: RouteConstants.home,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: RouteConstants.register,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const RegisterPage(),
      ),
    ),
  ],
  initialLocation: RouteConstants.home,
  errorBuilder: (context, state) => const Scaffold(
    body: Center(
      child: Text('Page not found'),
    ),
  ),
);