import 'package:flutter/material.dart';
import 'app_styles.dart';

/// Estilos de texto centralizados de la aplicación
/// 
/// Todos los TextStyle inline del proyecto han sido extraídos y optimizados aquí
/// para mantener consistencia, reducir redundancia y facilitar el mantenimiento.
class AppTextStyles {
  AppTextStyles._();

  // ============================================
  // 🎨 ESTILOS BASE RESPONSIVE
  // ============================================

  /// Helper para calcular fontSize responsive
  static double _fontSize(double small, double large, double tablet, bool isLargePhone, bool isTablet) {
    if (isTablet) return tablet;
    if (isLargePhone) return large;
    return small;
  }

  // ============================================
  // 📝 TÍTULOS Y ENCABEZADOS
  // ============================================

  /// Título grande (20/22/18) - Bold - Color primario
  /// Usado en: HomePage, AcademicStatusBlock
  static TextStyle titleLarge(bool isLargePhone, bool isTablet, [Color? color]) {
    return TextStyle(
      fontSize: _fontSize(18, 20, 22, isLargePhone, isTablet),
      fontWeight: FontWeight.bold,
      color: color ?? AppStyles.textPrimary,
    );
  }

  /// Título medio (18/20/16) - Bold - Color primario
  /// Usado en: CourseCard, CoursesListPage, CourseHistoryPage (blanco)
  static TextStyle titleMedium(bool isLargePhone, bool isTablet, [Color? color]) {
    return TextStyle(
      fontSize: _fontSize(16, 18, 20, isLargePhone, isTablet),
      fontWeight: FontWeight.bold,
      color: color ?? const Color(0xFF2C2C2C),
    );
  }

  /// Título pequeño (17/18/16) - Bold - Color primario
  /// Usado en: CourseCard, StudentInfoHeader (blanco)
  static TextStyle titleSmall(bool isLargePhone, bool isTablet, [Color? color]) {
    return TextStyle(
      fontSize: _fontSize(16, 17, 18, isLargePhone, isTablet),
      fontWeight: FontWeight.bold,
      color: color ?? const Color(0xFF2C2C2C),
    );
  }

  /// Título AppBar (18) - Bold
  static const titleAppBar = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Título AppBar con color blanco
  static const titleAppBarWhite = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // ============================================
  // 📝 TEXTO DE CUERPO
  // ============================================

  /// Texto normal (15/16/14) - Sin peso - Color secundario
  /// Usado en: HomePage (fecha), AttendanceHistoryCard (fecha)
  static TextStyle bodyMedium(bool isLargePhone, bool isTablet, [Color? color]) {
    return TextStyle(
      fontSize: _fontSize(14, 15, 16, isLargePhone, isTablet),
      color: color ?? AppStyles.textSecondary,
    );
  }

  /// Texto normal (14/15/13) - Sin peso - Color primario
  /// Usado en: HomePage (info), AcademicStatusBlock (label)
  static TextStyle bodySmall(bool isLargePhone, bool isTablet, [Color? color]) {
    return TextStyle(
      fontSize: _fontSize(13, 14, 15, isLargePhone, isTablet),
      color: color ?? AppStyles.textPrimary,
    );
  }

  /// Texto pequeño (13/14/12) - Sin peso - Color secundario
  /// Usado en: CourseCard (label), CourseHistoryPage (teacher), CoursesListPage (teacher)
  static TextStyle bodyTiny(bool isLargePhone, bool isTablet, [Color? color]) {
    return TextStyle(
      fontSize: _fontSize(12, 13, 14, isLargePhone, isTablet),
      color: color ?? const Color(0xFF757575),
    );
  }

  /// Texto muy pequeño (12/13/11) - Sin peso - Color secundario
  /// Usado en: AttendanceHistoryCard (hora), Bathroom (cleaning user)
  static TextStyle bodyMicro(bool isLargePhone, bool isTablet, [Color? color]) {
    return TextStyle(
      fontSize: _fontSize(11, 12, 13, isLargePhone, isTablet),
      color: color ?? const Color(0xFF757575),
    );
  }

  // ============================================
  // 📝 TEXTO EN NEGRITA
  // ============================================

  /// Texto bold (14/15/13) - Bold - Color primario
  /// Usado en: HomePage (info bold), CourseCard (valor)
  static TextStyle bodyBold(bool isLargePhone, bool isTablet, [Color? color]) {
    return TextStyle(
      fontSize: _fontSize(13, 14, 15, isLargePhone, isTablet),
      fontWeight: FontWeight.bold,
      color: color ?? AppStyles.textPrimary,
    );
  }

  /// Texto bold (15/16/14) - Bold - Color primario
  /// Usado en: AttendanceHistoryCard (fecha), CourseCard (mapa título)
  static TextStyle bodyBoldMedium(bool isLargePhone, bool isTablet, [Color? color]) {
    return TextStyle(
      fontSize: _fontSize(14, 15, 16, isLargePhone, isTablet),
      fontWeight: FontWeight.bold,
      color: color ?? const Color(0xFF2C2C2C),
    );
  }

  /// Texto bold (16/17/15) - Bold o w600 - Color primario
  /// Usado en: FriendsPage (nombre), Bathroom (nombre)
  static TextStyle bodyBoldLarge(bool isLargePhone, bool isTablet, {FontWeight fontWeight = FontWeight.bold, Color? color}) {
    return TextStyle(
      fontSize: _fontSize(15, 16, 17, isLargePhone, isTablet),
      fontWeight: fontWeight,
      color: color ?? const Color(0xFF2C2C2C),
    );
  }

  // ============================================
  // 📝 TEXTO CON COLOR DINÁMICO
  // ============================================

  /// Texto con color dinámico (13/14/12) - Bold
  /// Usado en: CourseCard (status, badge), AttendanceHistoryCard (badge)
  static TextStyle textWithColor(bool isLargePhone, bool isTablet, Color color, {FontWeight fontWeight = FontWeight.bold}) {
    return TextStyle(
      fontSize: _fontSize(12, 13, 14, isLargePhone, isTablet),
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Texto con color dinámico (13/14/12) - w500
  /// Usado en: Bathroom (status), CourseHistoryPage (stat label)
  static TextStyle textWithColorMedium(bool isLargePhone, bool isTablet, Color color) {
    return TextStyle(
      fontSize: _fontSize(12, 13, 14, isLargePhone, isTablet),
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  /// Texto con color dinámico (18/20/16) - Bold
  /// Usado en: CourseHistoryPage (stat value)
  static TextStyle textWithColorLarge(bool isLargePhone, bool isTablet, Color color) {
    return TextStyle(
      fontSize: _fontSize(16, 18, 20, isLargePhone, isTablet),
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  // ============================================
  // 📝 ESTILOS ESPECIALES DE COURSE CARD
  // ============================================

  /// Label secundario en CourseCard (13.5/14/13)
  static TextStyle courseCardLabel(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: isLargePhone ? 13.5 : (isTablet ? 14 : 13),
      color: const Color(0xFF757575),
    );
  }

  /// Valor principal en CourseCard (14.5/15/14)
  static TextStyle courseCardValue(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: isLargePhone ? 14.5 : (isTablet ? 15 : 14),
      fontWeight: FontWeight.bold,
      color: const Color(0xFF2C2C2C),
    );
  }

  /// Texto pequeño en CourseCard (12.5/13/12)
  static TextStyle courseCardSmall(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: isLargePhone ? 12.5 : (isTablet ? 13 : 12),
      color: const Color(0xFF757575),
    );
  }

  // ============================================
  // 📝 ESTILOS ESPECIALES DE STUDENT INFO
  // ============================================

  /// Badge de estado (10) - Bold - Blanco
  static const badgeSmall = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  /// Nombre del estudiante (17/18/16) - Bold - Blanco - height 1.2
  static TextStyle studentName(bool isLargePhone, bool isTablet) {
    return TextStyle(
      color: Colors.white,
      fontSize: _fontSize(16, 17, 18, isLargePhone, isTablet),
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
  }

  /// ID del estudiante (14/15/13) - Blanco70 - height 1.2
  static TextStyle studentId(bool isLargePhone, bool isTablet) {
    return TextStyle(
      color: Colors.white70,
      fontSize: _fontSize(13, 14, 15, isLargePhone, isTablet),
      height: 1.2,
    );
  }

  /// Semestre del estudiante (13/14/12) - Bold - Azul primario
  static TextStyle studentSemester(bool isLargePhone, bool isTablet) {
    return TextStyle(
      color: AppStyles.primaryColor,
      fontSize: _fontSize(12, 13, 14, isLargePhone, isTablet),
      fontWeight: FontWeight.bold,
    );
  }

  // ============================================
  // 📝 ESTILOS DE FORMULARIOS
  // ============================================

  /// Texto "Volver" en formularios (16) - w500 - Blanco
  static const formBack = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// Título de formulario (20) - Bold - Color primario
  static const formTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppStyles.textPrimary,
  );

  /// Label de campo (14) - w500 - Color primario
  static const formLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppStyles.textPrimary,
  );

  /// Enlace secundario (13) - Color primario
  static const formLink = TextStyle(
    color: AppStyles.primaryColor,
    fontSize: 13,
  );

  /// Texto de botón (16) - Bold
  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  /// Texto de botón con fontSize dinámico - Bold
  static TextStyle buttonTextDynamic(double fontSize) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );
  }

  // ============================================
  // 📝 ESTILOS ESPECIALES DE COURSE HISTORY
  // ============================================

  /// Título del curso en header (18/20/16) - Bold - Blanco
  static TextStyle courseHistoryTitle(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: _fontSize(16, 18, 20, isLargePhone, isTablet),
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  /// Nombre del docente en header (13/14/12) - Blanco con opacidad
  static TextStyle courseHistoryTeacher(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: _fontSize(12, 13, 14, isLargePhone, isTablet),
      color: Colors.white.withOpacity(0.85),
      fontWeight: FontWeight.normal,
    );
  }

  /// Label de estadística (10/11/9) - w500 - Blanco con opacidad
  static TextStyle courseHistoryStatLabel(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: _fontSize(9, 10, 11, isLargePhone, isTablet),
      color: Colors.white.withOpacity(0.9),
      fontWeight: FontWeight.w500,
    );
  }

  /// Texto informativo en banner (13/14/12) - height 1.4
  static TextStyle courseHistoryBanner(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: _fontSize(12, 13, 14, isLargePhone, isTablet),
      color: const Color(0xFF424242),
      height: 1.4,
    );
  }

  /// Mensaje vacío (18) - Gris
  static TextStyle get emptyMessage => TextStyle(
    fontSize: 18,
    color: Colors.grey[600],
  );

  /// Mensaje vacío responsive (16/18/14) - w500 - Gris
  static TextStyle emptyMessageResponsive(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: _fontSize(14, 16, 18, isLargePhone, isTablet),
      color: Colors.grey[600],
      fontWeight: FontWeight.w500,
    );
  }

  /// Texto secundario (13/14/12) - Gris500
  static TextStyle secondaryText(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: _fontSize(12, 13, 14, isLargePhone, isTablet),
      color: Colors.grey[500],
    );
  }

  // ============================================
  // 📝 ESTILOS ESPECIALES DE FRIENDS
  // ============================================

  /// Texto de búsqueda (16/17/15) - Gris800
  static TextStyle friendsSearchText(bool isLargePhone, bool isTablet) {
    return TextStyle(
      color: Colors.grey[800],
      fontSize: _fontSize(15, 16, 17, isLargePhone, isTablet),
    );
  }

  /// Hint de búsqueda (16/17/15) - Gris400
  static TextStyle friendsSearchHint(bool isLargePhone, bool isTablet) {
    return TextStyle(
      color: Colors.grey[400],
      fontSize: _fontSize(15, 16, 17, isLargePhone, isTablet),
    );
  }

  /// Título "Mis amigos" (14/15/13) - w600 - Gris700
  static TextStyle friendsMyFriendsTitle(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: _fontSize(13, 14, 15, isLargePhone, isTablet),
      fontWeight: FontWeight.w600,
      color: Colors.grey[700],
    );
  }

  /// Badge de estado (9) - Bold - Blanco
  static const friendsStatusBadge = TextStyle(
    color: Colors.white,
    fontSize: 9,
    fontWeight: FontWeight.bold,
  );

  /// Coordenadas en mapa (11/12/10) - Color secundario
  static TextStyle friendsMapCoordinates(bool isLargePhone, bool isTablet) {
    return TextStyle(
      fontSize: _fontSize(10, 11, 12, isLargePhone, isTablet),
      color: const Color(0xFF757575),
    );
  }

  // ============================================
  // 📝 ESTILOS ESPECIALES DE NAVIGATION
  // ============================================

  /// Texto en popup (14) - Gris
  static const navigationPopup = TextStyle(
    color: Colors.grey,
    fontSize: 14,
  );

  /// Título de error (20) - Bold - Color dinámico
  static TextStyle navigationErrorTitle(Color color) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Texto de error (14) - Negro87
  static const navigationErrorText = TextStyle(
    color: Colors.black87,
    fontSize: 14,
  );

  /// Texto secundario (14) - Gris600
  static TextStyle get navigationSecondary => TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
  );

  /// Texto pequeño (12) - Gris500
  static TextStyle get navigationSmall => TextStyle(
    fontSize: 12,
    color: Colors.grey[500],
  );

  // ============================================
  // 📝 ESTILOS ESPECIALES DE QR SCAN
  // ============================================

  /// Título principal (22) - Bold - Color primario
  static const qrScanTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppStyles.primaryColor,
  );

  /// Subtítulo (20) - Bold - Color primario
  static const qrScanSubtitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppStyles.primaryColor,
  );

  /// Texto descriptivo (15) - Color secundario - height 1.4
  static const qrScanDescription = TextStyle(
    fontSize: 15,
    color: Color(0xFF757575),
    height: 1.4,
  );

  /// Texto secundario (13) - Color secundario
  static const qrScanSecondary = TextStyle(
    fontSize: 13,
    color: Color(0xFF757575),
  );
}
