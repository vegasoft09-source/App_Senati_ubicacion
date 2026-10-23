import 'package:get_it/get_it.dart';
import '../../features/auth/data/data_sources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/index.dart' as auth_domain;
import '../../features/auth/domain/use_cases/login_use_case.dart';
import '../../features/auth/domain/use_cases/logout_use_case.dart';
import '../../features/auth/domain/use_cases/register_use_case.dart';
import '../../features/friends/data/data_sources/friends_remote_data_source.dart';
import '../../features/friends/data/repositories/friends_repository_impl.dart';
import '../../features/friends/domain/repositories/friends_repository.dart';
import '../../features/friends/domain/use_cases/add_friend_use_case.dart';
import '../../features/friends/domain/use_cases/get_friends_use_case.dart';
import '../../features/friends/domain/use_cases/remove_friend_use_case.dart';
import '../../features/friends/domain/use_cases/search_students_use_case.dart';
import '../../features/home/data/data_sources/home_remote_data_source.dart';
import '../../features/home/data/data_sources/location_data_source.dart';
import '../../features/home/data/data_sources/notification_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/use_cases/check_campus_status_use_case.dart';
import '../../features/home/domain/use_cases/check_courses_attendance_use_case.dart';
import '../../features/home/domain/use_cases/generate_course_history_use_case.dart';
import '../../features/home/domain/use_cases/get_course_status_use_case.dart';
import '../../features/home/domain/use_cases/get_student_data_use_case.dart';
import '../../features/home/domain/use_cases/initialize_notifications_use_case.dart';
import '../../features/home/domain/use_cases/load_student_with_courses_use_case.dart';
import '../../features/home/domain/use_cases/logout_use_case.dart' as home_logout;
import '../../features/home/domain/use_cases/schedule_notifications_use_case.dart';
import '../../features/home/domain/use_cases/update_location_use_case.dart';
import '../../features/home/domain/use_cases/update_location_periodically_use_case.dart';
import '../../features/home/domain/use_cases/validate_attendance_use_case.dart';
import '../../features/navigation/data/data_sources/svg_map_data_source.dart';
import '../../features/navigation/data/data_sources/firestore_navigation_data_source.dart';
import '../../features/navigation/data/repositories/navigation_repository_impl.dart';
import '../../features/navigation/data/services/graph_initializer.dart';
import '../../features/navigation/data/services/navigation_auto_initializer.dart';
import '../../features/navigation/domain/repositories/navigation_repository.dart';
import '../../features/navigation/domain/use_cases/initialize_floor_graph.dart';
import '../../features/navigation/domain/use_cases/get_route_to_room.dart';
import '../../features/navigation/domain/use_cases/initialize_edges_use_case.dart';
import '../../features/navigation/domain/use_cases/find_nearest_elevator_node.dart';
import '../../core/services/sensor_service.dart';

/// Service Locator global usando GetIt
final sl = GetIt.instance;

/// Inicializar todas las dependencias del proyecto
Future<void> init() async {
  // ============================================
  // 🔵 DATA SOURCES
  // ============================================
  
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(),
  );

  // Friends
  sl.registerLazySingleton<FriendsRemoteDataSource>(
    () => FriendsRemoteDataSource(),
  );

  // Home
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSource(),
  );
  sl.registerLazySingleton<LocationDataSource>(
    () => LocationDataSource(),
  );
  sl.registerLazySingleton<NotificationDataSource>(
    () => NotificationDataSource(),
  );

  // Navigation
  sl.registerLazySingleton<SvgMapDataSource>(
    () => SvgMapDataSource(),
  );
  sl.registerLazySingleton<FirestoreNavigationDataSource>(
    () => FirestoreNavigationDataSource(),
  );

  // ============================================
  // 🔴 CORE SERVICES
  // ============================================
  
  // Sensor Service (singleton global - se inicia al arrancar la app)
  sl.registerLazySingleton<SensorService>(
    () => SensorService(),
  );

  // ============================================
  // 🟢 REPOSITORIES
  // ============================================
  
  // Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // Friends
  sl.registerLazySingleton<FriendsRepository>(
    () => FriendsRepositoryImpl(sl<FriendsRemoteDataSource>()),
  );

  // Home
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      sl<HomeRemoteDataSource>(),
      sl<LocationDataSource>(),
    ),
  );

  // Navigation
  sl.registerLazySingleton<NavigationRepository>(
    () => NavigationRepositoryImpl(
      svgDataSource: sl<SvgMapDataSource>(),
      firestoreDataSource: sl<FirestoreNavigationDataSource>(),
    ),
  );

  // ============================================
  // 🟡 USE CASES
  // ============================================
  
  // Auth
  sl.registerLazySingleton(() => auth_domain.GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));

  // Friends
  sl.registerLazySingleton(() => AddFriendUseCase(sl<FriendsRepository>()));
  sl.registerLazySingleton(() => GetFriendsUseCase(sl<FriendsRepository>()));
  sl.registerLazySingleton(() => RemoveFriendUseCase(sl<FriendsRepository>()));
  sl.registerLazySingleton(() => SearchStudentsUseCase(sl<FriendsRepository>()));

  // Home
  sl.registerLazySingleton(() => CheckCampusStatusUseCase());
  sl.registerLazySingleton(() => CheckCoursesAttendanceUseCase(
    sl<LocationDataSource>(),
    sl<GetCourseStatusUseCase>(),
    sl<ValidateAttendanceUseCase>(),
  ));
  sl.registerLazySingleton(() => GenerateCourseHistoryUseCase());
  sl.registerLazySingleton(() => GetCourseStatusUseCase());
  sl.registerLazySingleton(() => GetStudentDataUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton(() => InitializeNotificationsUseCase(sl<NotificationDataSource>()));
  sl.registerLazySingleton(() => LoadStudentWithCoursesUseCase(
    getStudentDataUseCase: sl<GetStudentDataUseCase>(),
    generateCourseHistoryUseCase: sl<GenerateCourseHistoryUseCase>(),
  ));
  sl.registerLazySingleton(() => home_logout.LogoutUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton(() => ScheduleNotificationsUseCase(sl<NotificationDataSource>()));
  sl.registerLazySingleton(() => UpdateLocationUseCase(sl<HomeRepository>()));
  sl.registerLazySingleton(() => UpdateLocationPeriodicallyUseCase(
    sl<LocationDataSource>(),
    sl<CheckCampusStatusUseCase>(),
    sl<UpdateLocationUseCase>(),
    sl<auth_domain.GetCurrentUserUseCase>(),
  ));
  sl.registerLazySingleton(() => ValidateAttendanceUseCase(sl<GetCourseStatusUseCase>()));

  // Navigation
  sl.registerLazySingleton<GraphInitializer>(
    () => GraphInitializer(sl<NavigationRepository>()),
  );
  sl.registerLazySingleton<NavigationAutoInitializer>(
    () => NavigationAutoInitializer(
      repository: sl<NavigationRepository>(),
      svgDataSource: sl<SvgMapDataSource>(),
      graphInitializer: sl<GraphInitializer>(),
    ),
  );
  sl.registerLazySingleton(() => InitializeFloorGraphUseCase(sl<NavigationRepository>()));
  sl.registerLazySingleton(() => InitializeEdgesUseCase(sl<GraphInitializer>()));
  sl.registerLazySingleton(() => GetRouteToRoomUseCase(sl<NavigationRepository>()));
  sl.registerLazySingleton(() => FindNearestElevatorNodeUseCase(sl<NavigationRepository>()));

  // ============================================
  // 🚀 INICIALIZAR SERVICIOS GLOBALES
  // ============================================
  
  final sensorService = sl<SensorService>();
  sensorService.start();

}

