import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athlete_alumni/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:athlete_alumni/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:athlete_alumni/features/auth/domain/repositories/auth_repository.dart';
import 'package:athlete_alumni/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:athlete_alumni/features/auth/domain/usecases/auth_usecase.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // Core & External
  await _initExternal();
  
  // Features
  await _initAuth();
}

Future<void> _initExternal() async {
  // Supabase
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}

Future<void> _initAuth() async {
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      supabaseClient: sl<SupabaseClient>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<SupabaseClient>(),
      remoteDataSource: sl<AuthRemoteDataSource>(),
    ),
  );

  // Use Cases
  // sl
  //   ..registerLazySingleton(() => SignInUseCase(sl()))
  //   ..registerLazySingleton(() => SignUpUseCase(sl()))
  //   ..registerLazySingleton(() => SignOutUseCase(sl()))
  //   ..registerLazySingleton(() => GetCurrentAthleteUseCase(sl()))
  //   ..registerLazySingleton(() => IsSignedInUseCase(sl()));

  // Blocs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );
}
