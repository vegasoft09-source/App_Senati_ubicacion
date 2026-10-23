import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../app/styles/app_styles.dart';
import '../../../../../app/styles/text_styles.dart';
import '../../../../../app/styles/app_spacing.dart';
import '../../../../core/widgets/empty_states/index.dart';
import '../../../../core/widgets/primary_button/primary_button.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import '../../domain/index.dart';
import '../widgets/student_info_header.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../widgets/home_drawer.dart';
import '../models/drawer_menu_item.dart';
import '../../../friends/presentation/pages/friends_page.dart';
import '../../../courses/presentation/pages/courses_list_page.dart';
import '../../../identification/presentation/pages/identification_page.dart';
import '../../../notes/presentation/pages/notes_page.dart';
import '../../data/models/student_model.dart';
import '../widgets/academic_status_block.dart';
import '../widgets/section_header.dart';
import '../widgets/info_banner.dart';

/// Página principal de home (completamente refactorizada con Clean Architecture)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Use cases
  late final LoadStudentWithCoursesUseCase _loadStudentWithCoursesUseCase;
  late final GetCourseStatusUseCase _getCourseStatusUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final InitializeNotificationsUseCase _initializeNotificationsUseCase;
  late final ScheduleNotificationsUseCase _scheduleNotificationsUseCase;
  late final CheckCoursesAttendanceUseCase _checkCoursesAttendanceUseCase;
  late final UpdateLocationPeriodicallyUseCase _updateLocationPeriodicallyUseCase;

  // Estado
  StudentEntity? _student;
  bool _loading = true;
  String _campusStatus = "Desconocido";
  Map<String, AttendanceStatus> _courseAttendanceStatus = {};
  final Map<String, DateTime?> _courseFirstEntryTime = {};

  // Timers
  Timer? _gpsTimer;
  Timer? _courseStatusTimer;
  Timer? _attendanceCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _loadStudentData();
    _initializeNotificationsUseCase.call();
    _startTimers();
  }

  void _initializeDependencies() {
    // Obtener use cases del service locator
    _loadStudentWithCoursesUseCase = sl<LoadStudentWithCoursesUseCase>();
    _getCourseStatusUseCase = sl<GetCourseStatusUseCase>();
    _logoutUseCase = sl<LogoutUseCase>();
    _initializeNotificationsUseCase = sl<InitializeNotificationsUseCase>();
    _scheduleNotificationsUseCase = sl<ScheduleNotificationsUseCase>();
    _checkCoursesAttendanceUseCase = sl<CheckCoursesAttendanceUseCase>();
    _updateLocationPeriodicallyUseCase = sl<UpdateLocationPeriodicallyUseCase>();
  }

  Future<void> _loadStudentData() async {
    try {
      // Delegar toda la lógica de carga y procesamiento al use case
      final student = await _loadStudentWithCoursesUseCase.call();
      
      if (!mounted) return;
      
      if (student != null) {
        // Inicializar todos los cursos como "Presente" por defecto
        // (excepto Redes de Computadoras que se manejará después de las 7:15 PM)
        final initialStatus = <String, AttendanceStatus>{};
        for (var course in student.coursesToday) {
          // No inicializar Redes de Computadoras, se manejará dinámicamente
          if (!course.name.toUpperCase().contains('REDES DE COMPUTADORAS')) {
            initialStatus[course.name] = AttendanceStatus.present;
          }
        }
        
        setState(() {
          _student = student;
          _courseAttendanceStatus = initialStatus;
          _loading = false;
        });

        // Programar notificaciones
        await _scheduleNotificationsUseCase.call(student.coursesToday);
      } else {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    } catch (e) {
      print('Error cargando datos del estudiante: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }


  void _startTimers() {
    // Actualizar ubicación inmediatamente al iniciar
    _updateLocation();
    
    // Timer para actualizar ubicación cada 3 segundos (más frecuente para respuesta más rápida)
    // Iniciar después de un pequeño delay para asegurar que todas las dependencias estén inicializadas
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _gpsTimer = Timer.periodic(const Duration(seconds: 3), (_) {
          if (mounted) _updateLocation();
        });
      }
    });

    // Timer para actualizar estado de cursos cada minuto
    _courseStatusTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });

    // Timer para validar asistencia cada 30 segundos
    _attendanceCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _checkCourseAttendance();
    });
  }

  Future<void> _updateLocation() async {
    final status = await _updateLocationPeriodicallyUseCase.call();
    
    if (status != null && mounted) {
      setState(() {
        _campusStatus = status;
      });
    }
  }

  Future<void> _checkCourseAttendance() async {
    if (_student == null) return;

    try {
      final updatedStatus = await _checkCoursesAttendanceUseCase.call(
        student: _student!,
        courseFirstEntryTime: _courseFirstEntryTime,
        currentAttendanceStatus: _courseAttendanceStatus,
        campusStatus: _campusStatus, // Pasar el estado del campus
      );

      if (mounted) {
        setState(() {
          _courseAttendanceStatus = updatedStatus;
        });
      }
    } catch (e) {
      print('Error verificando asistencia: $e');
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _logoutUseCase.call();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error cerrando sesión: $e');
    }
  }

  List<CourseEntity> _sortCoursesByTime(List<CourseEntity> courses) {
    final sorted = List<CourseEntity>.from(courses);
    sorted.sort((a, b) {
      final timeA = _parseTime(a.startTime);
      final timeB = _parseTime(b.startTime);

      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1;
      if (timeB == null) return -1;

      return timeA.compareTo(timeB);
    });
    return sorted;
  }

  DateTime? _parseTime(String timeStr) {
    try {
      final now = DateTime.now();
      final parts = timeStr.trim().split(' ');
      if (parts.length != 2) return null;

      final timePart = parts[0];
      final amPm = parts[1].toUpperCase();

      final timeParts = timePart.split(':');
      if (timeParts.length != 2) return null;

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (amPm == 'PM' && hour != 12) {
        hour += 12;
      } else if (amPm == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }


  String _getCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    const weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} De ${months[now.month - 1]} De ${now.year}';
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    _courseStatusTimer?.cancel();
    _attendanceCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargePhone = screenSize.width >= 400 && !isTablet;

    if (_loading) {
      return Scaffold(
        backgroundColor: AppStyles.surfaceColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_student == null) {
      return Scaffold(
        backgroundColor: AppStyles.surfaceColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final sortedCourses = _sortCoursesByTime(_student!.coursesToday);

    // Construir items del menú
    final menuItems = _buildMenuItems(context, isLargePhone, isTablet);

    return Scaffold(
      backgroundColor: AppStyles.surfaceColor,
      drawer: HomeDrawer(
        menuItems: menuItems,
        isLargePhone: isLargePhone,
        isTablet: isTablet,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header con información del estudiante
                Builder(
                  builder: (context) => StudentInfoHeader(
                    student: _student!,
                    campusStatus: _campusStatus,
                    isLargePhone: isLargePhone,
                    isTablet: isTablet,
                    onMenuTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                // Contenido scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isLargePhone ? 20 : (isTablet ? 24 : 16),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 800 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sección de Información Académica
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: isLargePhone ? AppSpacing.spacingXL : (isTablet ? 28 : 20),
                            ),
                            child: AcademicStatusBlock(student: _student!),
                          ),
                          // Divider
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[300],
                          ),
                          SizedBox(
                            height: isLargePhone ? 24 : (isTablet ? 28 : 20),
                          ),
                          // Sección de Cursos Programados
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título con icono y fecha
                              SectionHeader(
                                icon: Icons.access_time,
                                title: 'Cursos Programados',
                                iconColor: AppStyles.primaryColor,
                              ),
                              SizedBox(
                                height: isLargePhone ? 10 : (isTablet ? 12 : 8),
                              ),
                              Text(
                                _getCurrentDate(),
                                style: AppTextStyles.bodyMedium(isLargePhone, isTablet),
                              ),
                              SizedBox(
                                height: isLargePhone ? 10 : (isTablet ? 12 : 8),
                              ),
                              Text(
                                'Total de cursos: ${sortedCourses.length}',
                                style: AppTextStyles.bodyBold(isLargePhone, isTablet),
                              ),
                              SizedBox(
                                height: isLargePhone
                                    ? 22
                                    : (isTablet ? 24 : 20),
                              ),
                              // Lista de cursos ordenados por horario
                              if (sortedCourses.isEmpty)
                                EmptyState(
                                  icon: Icons.school_outlined,
                                  message: 'No hay cursos programados para hoy',
                                )
                              else
                                ...sortedCourses.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final course = entry.value;
                                  final attendanceStatus = _courseAttendanceStatus[course.name];
                                  
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: isLargePhone ? 18 : (isTablet ? 20 : AppSpacing.spacingL),
                                    ),
                                    child: CourseCard(
                                      course: course,
                                      index: index,
                                      attendanceStatus: attendanceStatus,
                                      getCourseStatusUseCase: _getCourseStatusUseCase,
                                    ),
                                  );
                                }),
                              // Información adicional
                              Padding(
                                padding: EdgeInsets.only(
                                  top: isLargePhone ? 18 : (isTablet ? 20 : AppSpacing.spacingL),
                                ),
                                child: InfoBanner(
                                  icon: Icons.location_on,
                                  message: 'Presiona el botón "Ver Ubicación en Mapa" en cada curso para navegar al salón',
                                  iconColor: AppStyles.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la lista de items del menú del drawer
  List<DrawerMenuItem> _buildMenuItems(
    BuildContext context,
    bool isLargePhone,
    bool isTablet,
  ) {
    return [
      // Botón Cursos
      DrawerMenuItem(
        icon: Icons.folder,
        title: 'Cursos',
        onTap: () {
          Navigator.pop(context);
          if (_student != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CoursesListPage(
                  courses: _student!.coursesToday.map((c) {
                    return CourseModel(
                      name: c.name,
                      type: c.type,
                      startTime: c.startTime,
                      endTime: c.endTime,
                      duration: c.duration,
                      teacher: c.teacher,
                      locationCode: c.locationCode,
                      locationDetail: c.locationDetail,
                      classroomLatitude: c.classroomLatitude,
                      classroomLongitude: c.classroomLongitude,
                      classroomRadius: c.classroomRadius,
                      history: c.history,
                    );
                  }).toList(),
                ),
              ),
            );
          }
        },
      ),
      // Botón Amigos
      DrawerMenuItem(
        icon: Icons.people,
        title: 'Amigos',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FriendsPage(),
            ),
          );
        },
      ),
      // Botón Notas
      DrawerMenuItem(
        icon: Icons.note,
        title: 'Notas',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotesPage(),
            ),
          );
        },
      ),
      // Botón Identificación
      DrawerMenuItem(
        icon: Icons.badge,
        title: 'Identificación',
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IdentificationPage(),
            ),
          );
        },
      ),
      // Botón Cerrar Sesión
      DrawerMenuItem(
        icon: Icons.logout,
        title: 'Cerrar Sesión',
        onTap: () {
          Navigator.pop(context);
          _handleLogout();
        },
        showSeparator: false,
        isLogout: true,
      ),
    ];
  }

}
