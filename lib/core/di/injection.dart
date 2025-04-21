import 'package:athlete_alumni/features/athletes/presentation/bloc/filter_athletes_bloc.dart';
import 'package:athlete_alumni/features/profile/domain/usecases/get_profile_image_url_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athlete_alumni/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:athlete_alumni/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:athlete_alumni/features/auth/domain/repositories/auth_repository.dart';
import 'package:athlete_alumni/features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/upload_profile_image_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/edit_profile_bloc.dart';
import '../../features/profile/presentation/bloc/upload_image_bloc.dart';
import '../../features/profile/data/services/image_picker_service.dart';
import '../network/network_info.dart';

// Feature - Athletes
import '../../features/athletes/domain/repositories/i_athlete_repository.dart';
import '../../features/athletes/data/repositories/local_athlete_repository.dart';
import '../../features/athletes/data/repositories/supabase_athlete_repository.dart';
import '../../features/athletes/domain/usecases/get_all_athletes_usecase.dart';
import '../../features/athletes/domain/usecases/get_athletes_by_status_usecase.dart';
import '../../features/athletes/domain/usecases/search_athletes_usecase.dart';
import '../../features/athletes/domain/usecases/get_athlete_by_id_usecase.dart';
// Athlete BLoCs
import '../../features/athletes/presentation/bloc/athlete_bloc.dart';
import '../../features/athletes/presentation/bloc/athlete_details_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core & External
  await _initExternal();
  
  // Features
  await _initAuth();
  await _initProfile();
  
  // Register for Athletes feature
  _registerAthletesDependencies();
}

Future<void> _initExternal() async {
  // Supabase
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  
  // HTTP Client
  sl.registerLazySingleton(() => http.Client());
  
  // Network info
  // For web, use the WebNetworkInfoImpl that always returns true for development
  sl.registerLazySingleton<NetworkInfo>(() => WebNetworkInfoImpl());
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
      remoteDataSource: sl<AuthRemoteDataSource>(),
    ),
  );

  // Blocs - Simplified without the use cases
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );
}

Future<void> _initProfile() async {
  // BLoCs
  sl.registerFactory(() => ProfileBloc(
    getProfileUseCase: sl<GetProfileUseCase>(),
    updateProfileUseCase: sl<UpdateProfileUseCase>(),
    uploadProfileImageUseCase: sl<UploadProfileImageUseCase>(),
    getProfileImageUrlUseCase: sl<GetProfileImageUrlUseCase>(),
  ));
  
  sl.registerFactory(() => EditProfileBloc(
    updateProfileUseCase: sl<UpdateProfileUseCase>(),
  ));
  
  sl.registerFactory(() => UploadImageBloc(
    uploadProfileImageUseCase: sl<UploadProfileImageUseCase>(),
  ));
  
  // Services
  sl.registerLazySingleton(() => ImagePickerService());
  
  // Use cases
  sl.registerLazySingleton(() => GetProfileUseCase());
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UploadProfileImageUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => GetProfileImageUrlUseCase(sl<ProfileRepository>()));
  
  // Repository
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(
    remoteDataSource: sl<ProfileRemoteDataSource>(),
    networkInfo: sl<NetworkInfo>(),
  ));
  
  // Data sources - Update to use SupabaseClient
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(
    supabaseClient: sl<SupabaseClient>(),
  ));
}

void _registerAthletesDependencies() {
  // Repositories
  sl.registerLazySingleton<IAthleteRepository>(
    () => SupabaseAthleteRepository(
      supabaseClient: sl<SupabaseClient>(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton  (
    () => GetAllAthletesUseCase(sl()),
  );
  
  sl.registerLazySingleton(
    () => GetAthletesByStatusUseCase(sl()),
  );
  
  sl.registerLazySingleton(
    () => SearchAthletesUseCase(sl()),
  );
  
  sl.registerLazySingleton(
    () => GetAthleteByIdUseCase(sl()),
  );
  
  // BLoCs
  sl.registerFactory(
    () => AthleteBloc(
      getAllAthletesUseCase: sl(),
      getAthletesByStatusUseCase: sl(),
      searchAthletesUseCase: sl(),
      getAthleteByIdUseCase: sl(),
    ),
  );
  
  sl.registerFactory(
    () => AthleteDetailsBloc(
      getAthleteByIdUseCase: sl(),
    ),
  );
  
  sl.registerFactory(
    () => FilterAthletesBloc(),
  );
}
