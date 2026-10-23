# Plan de tareas – App_ubicacion_senati

Un solo documento: vulnerabilidades detectadas + tareas para corregirlas y llevar la app a producción (SENATI).
Las claves reales NO se copian aquí.

**Responsables:** `APP` = Flutter · `FB` = Firebase (Firestore, reglas, Functions, Auth) · `WEB` = panel admin · `OPS` = CI/CD, repo, publicación · `LEG` = privacidad y relación con SENATI

**Prioridad:** 🔴 hacer ya · 🟠 siguiente · 🟡 luego

## Decisiones tomadas
- Equipo de varias personas; demo en un aula; objetivo final: uso por SENATI; sin presupuesto (capas gratuitas).
- **Todo el backend se queda en Firebase por ahora:** Firestore, Auth, Cloud Functions, App Check, FCM y Crashlytics. No se usa PostgreSQL ni API propia.
- La lógica que no puede confiar en el cliente (asistencia, chatbot) va en **Cloud Functions** (TypeScript).
- Gemini se llama solo desde una Cloud Function.
- Si SENATI exige más adelante su propia infraestructura o reportes SQL, se reevalúa (ver T-72).

## Cambios de alcance
- **Se eliminó el chatbot de Gemini**: ya no hay key de Gemini en el código (T-01 y T-30 quedan sin objeto). Pendiente fuera del código: **revocar la key antigua** en Google AI Studio, porque sigue en el historial de git.
- **Se eliminó la pantalla de Mapbox**: ya no hay token en el código (T-02). Pendiente: **rotar el token** en la cuenta de Mapbox.
- **Se eliminó la función de baños** (T-44 ya no aplica). Pendiente: quitar la regla `bathrooms` de `firestore.rules` (se hace en T-03) y borrar la colección en la consola de Firebase.
- Para compilar en Android hace falta **JDK 21** (el Java 25 de Android Studio falla con Gradle 8.12): `flutter config --jdk-dir=<ruta a un JDK 21>`.

## Decisiones pendientes
- [ ] **D1** ¿Se usa el plan Blaze de Firebase? Cloud Functions requiere Blaze (tiene capa gratuita, pero pide tarjeta). Si no hay tarjeta, ver alternativa en T-20.
- [ ] **D2** Contacto en SENATI (SSO, hosting, privacidad).

---

## SPRINT 0 – Cerrar riesgos (🔴 empezar hoy)

### T-01 · ~~Revocar y sacar la API key de Gemini~~ · `APP` · ✅ código / ⏳ revocar la key
Problema (crítico): hardcodeada en `lib/features/chatbot/data/data_sources/chatbot_service.dart:16`, en el historial de git y en el APK.
- [ ] Revocar la key actual en Google AI Studio y crear una nueva.
- [ ] Quitarla del código; leerla con `String.fromEnvironment('GEMINI_KEY')` y `--dart-define` (temporal hasta T-30).
- [ ] Restringir la nueva key por app/API y poner cuota baja.
- **Hecho cuando:** no hay ninguna key en el repo y el chatbot funciona con `--dart-define`.

### T-02 · ~~Sacar y restringir el token de Mapbox~~ · `APP` · ✅ código / ⏳ rotar el token
Problema: token `pk.` hardcodeado en `mapbox_map_page.dart:19` y se imprime parcialmente en `:69`.
- [ ] Moverlo a `--dart-define=MAPBOX_TOKEN`.
- [ ] Quitar el `print` del token.
- [ ] Restringirlo por paquete en Mapbox y rotarlo.
- **Hecho cuando:** `grep "pk\."` en `lib/` no devuelve nada.

### T-03 · Endurecer `firestore.rules` · `FB` · 🔴
Problema (alto): cualquier usuario autenticado escribe en `mapas`, `salones` y `bathrooms`; hay regla comodín de lectura global.
- [ ] `mapas` y `salones`: escritura solo con custom claim `admin == true`.
- [ ] Quitar la regla de `bathrooms` (la función ya no existe).
- [ ] Validar esquema en `usuarios` (`hasOnly`, tipos, rangos): que un cliente no pueda escribir `estado` arbitrario.
- [ ] Eliminar la regla comodín `match /{document=**}`.
- [ ] Pruebas con el emulador de Firestore.
- **Hecho cuando:** un usuario normal no puede escribir en `mapas`/`salones` y las pruebas pasan.

### T-04 · Activar Firebase App Check · `FB` · 🔴
- [ ] Activar Play Integrity y exigirlo en Firestore, Auth y Functions.
- **Hecho cuando:** peticiones sin token de App Check son rechazadas.

### T-05 · Limpiar el repositorio · `OPS` · 🔴
Problema: `assets/lib_ext/` (44 archivos Dart) es una copia legada dentro de los assets.
- [ ] Borrar `assets/lib_ext/` (queda en el historial).
- [ ] Revisar `.gitignore` (`build/`, llaves, archivos locales).
- [ ] Eliminar o completar `features/notes` y `features/identification`.
- [ ] Decidir qué plataformas se mantienen (`linux`, `macos`, `windows`, `web`).
- **Hecho cuando:** el APK no incluye código legado y `flutter analyze` pasa.

### T-06 · Organizar el trabajo en equipo · `OPS` · 🔴
- [ ] Proteger `main` y exigir PR con al menos 1 revisión.
- [ ] Convención de ramas (`feat/…`, `fix/…`) y de commits.
- [ ] `README`: requisitos, cómo ejecutar, variables `--dart-define`.
- [ ] Plantillas de PR e issues; crear estas tareas como issues/tablero.
- **Hecho cuando:** nadie puede pushear a `main` directamente.

### T-07 · Decidir si se limpia el historial de git · `OPS` · 🔴
- [ ] Decidir si se ejecuta `git filter-repo` para borrar las keys antiguas (rotar en T-01/T-02 es obligatorio igual).
- **Hecho cuando:** hay decisión documentada y, si aplica, el historial está limpio.

---

## SPRINT 1 – Modelo de datos en Firestore (🟠)

### T-10 · Diseñar el esquema de Firestore · `FB` · 🟠
Problema (medio): hay `usuarios` y `students` duplicados, campos mezclados (`IdEstudiante`, `NameEstudent`, `lat`, `lon`, `estado`) y fechas como string ISO.
- [ ] Documentar el modelo en un archivo `FIRESTORE_ESQUEMA.md`: colecciones, campos, tipos y quién puede leer/escribir cada uno.
- [ ] Una convención única de nombres e idioma (camelCase).
- [ ] Colecciones propuestas: `users`, `courses`, `enrollments`, `rooms`, `attendance/{uid}/records`, `friendships`, `presence`, `bathrooms`, `maps/{floor}` y `mapVersions`.
- [ ] Timestamps con `Timestamp`/`serverTimestamp`, nunca `DateTime.now().toIso8601String()`.
- [ ] Revisión del esquema en equipo.
- **Hecho cuando:** el esquema está aprobado y versionado en el repo.

### T-11 · Índices y configuración de Firestore · `FB` · 🟠
- [ ] Crear `firestore.indexes.json` con los índices necesarios.
- [ ] Activar persistencia offline donde corresponda.
- [ ] Configurar el emulador de Firebase para desarrollo local (Auth + Firestore + Functions).
- **Hecho cuando:** el equipo desarrolla contra el emulador sin tocar producción.

### T-12 · Entornos dev / prod · `OPS` + `FB` · 🟠
- [ ] Proyectos de Firebase separados (`dev` y `prod`).
- [ ] Flavors de Flutter para cada uno.
- **Hecho cuando:** probar no escribe en la base de datos real.

### T-13 · Proyecto de Cloud Functions · `FB` · 🟠 (⛔D1)
- [ ] Carpeta `functions/` en TypeScript con lint y tests.
- [ ] Funciones base: `onUserCreate`, `setAdminClaim` (solo ejecutable por un admin existente).
- **Hecho cuando:** se despliega una función de prueba al entorno `dev`.

### T-14 · Datos semilla fuera de la app · `FB` · 🟠
- [ ] Mover `initialize_salones.dart` (529 líneas) e `initialize_bathrooms.dart` a un script de administración (Node con Admin SDK).
- [ ] Importar salones, cursos y horarios desde CSV/JSON.
- **Hecho cuando:** la app no escribe datos semilla en producción.

---

## SPRINT 2 – Asistencia confiable (🟠)

### T-20 · Función de asistencia en servidor · `FB` · 🟠 (⛔D1)
Problema (alto): `validate_attendance_use_case.dart` devuelve `present` para todos los cursos salvo uno hardcodeado ("REDES DE COMPUTADORAS", 7:15 PM), y todo se calcula en el cliente: GPS falso u hora manipulada bastan.
- [ ] Cloud Function `registerAttendance`: recibe posición y curso; decide con la hora del servidor y la geocerca del campus (cálculo por distancia/polígono en la función).
- [ ] Reglas por curso en Firestore (`graceMinutes`, `lateMinutes`), sin nombres hardcodeados.
- [ ] Estados: `present`, `late`, `absent`, `justified`.
- [ ] Límite de peticiones por usuario.
- [ ] Reglas de Firestore: el cliente **no puede** escribir en `attendance`; solo la función.
- *Si no se puede usar Blaze (D1):* mantener la lógica en la app pero escribiendo con `serverTimestamp` y reglas que validen la hora; es menos seguro y debe quedar documentado como limitación.
- **Hecho cuando:** modificar la hora del móvil no cambia el resultado.

### T-21 · Anti-spoofing de ubicación · `FB` + `APP` · 🟠
- [ ] Detectar `Position.isMocked` y enviarlo a la función.
- [ ] Rechazar saltos de velocidad imposibles y precisión baja.
- **Hecho cuando:** una app de GPS falso es detectada y queda registrada.

### T-22 · Historial persistente de asistencia · `FB` · 🟠
Problema: `courseFirstEntryTime` vive en memoria y se pierde al cerrar la app.
- [ ] Guardar cada registro en `attendance/{uid}/records/{fecha_curso}` con estado, hora y ubicación validada.
- **Hecho cuando:** cerrar la app no pierde la asistencia del día.

### T-23 · Migrar la app a la nueva asistencia · `APP` · 🟠
- [ ] Reemplazar `ValidateAttendanceUseCase` por la llamada a `registerAttendance`.
- [ ] Borrar el código muerto `_validateNormalAttendance` y el caso especial de Redes.
- [ ] Pantalla de historial leyendo `attendance`.
- [ ] Cola de eventos sin conexión que se envía al reconectar.
- **Hecho cuando:** la asistencia en la app coincide con la del servidor.

### T-24 · Ubicación y batería · `APP` · 🟠
Problema: `Timer.periodic` cada 3 s para GPS más otros dos timers en `home_page`; escribe en Firestore cada ciclo (costo en lecturas/escrituras).
- [ ] Usar `getPositionStream` con `distanceFilter` y precisión media.
- [ ] Escribir en Firestore solo cuando cambia el estado (dentro/fuera) o cada N minutos.
- [ ] Servicio en primer plano solo si se necesita segundo plano.
- **Hecho cuando:** baja el consumo de batería y las escrituras por usuario.

---

## SPRINT 3 – Usuarios, roles y privacidad (🟠)

### T-30 · ~~Mover el chatbot a una Cloud Function~~ · NO APLICA (chatbot eliminado)
- [ ] Función `chat` que valida el usuario (y App Check) y limita peticiones.
- [ ] Guardar la key de Gemini en Secret Manager, no en la app.
- [ ] Prompt de sistema con contexto del campus y límite de longitud.
- [ ] La app deja de llamar a Gemini directamente.
- **Hecho cuando:** no hay key de Gemini en la app.

### T-31 · Unificar `usuarios` y `students` · `FB` + `APP` · 🟠
- [ ] Un solo modelo de usuario; script de migración de los datos existentes.
- [ ] Actualizar registro, amigos y GPS al nuevo modelo.
- **Hecho cuando:** solo existe una colección de usuarios.

### T-32 · Roles y cuentas institucionales · `FB` · 🟠 (⛔D2)
- [ ] Roles: estudiante, docente, administrador (custom claims asignados por función).
- [ ] Registro solo con correo institucional o invitación.
- [ ] Verificación de correo y recuperación de contraseña.
- **Hecho cuando:** un correo ajeno no puede registrarse.

### T-33 · Búsqueda de estudiantes segura · `FB` + `APP` · 🟠
Problema (alto): `searchStudentByName` descarga toda la colección `usuarios` y filtra en el dispositivo; Firestore no tiene búsqueda de texto.
- [ ] Guardar `nameLower` y consultar por prefijo (`>=` / `<`) con `limit`.
- [ ] Alternativa: función `searchStudents` que devuelva solo nombre, id y foto.
- **Hecho cuando:** el cliente nunca recibe más de N resultados ni datos sensibles.

### T-34 · Privacidad de ubicación · `FB` + `APP` + `LEG` · 🟠
Problema (alto): `lat`/`lon` en el mismo documento que los datos personales.
- [ ] Separar la presencia en `presence/{uid}` (solo `dentro/fuera` y hora) y no guardar coordenadas exactas, salvo necesidad justificada.
- [ ] Reglas: solo amigos aceptados pueden leer `presence`.
- [ ] Amistades con solicitud y aceptación.
- [ ] Política de retención y borrado de ubicaciones antiguas (función programada).
- **Hecho cuando:** un amigo no puede ver tus coordenadas exactas.

### T-35 · Sesión segura en el cliente · `APP` · 🟠
- [ ] Usar `flutter_secure_storage` para datos de sesión (`tokenKey`, `userKey`).
- [ ] Verificar que el QR de login no contiene credenciales reutilizables.
- **Hecho cuando:** nada sensible está en almacenamiento sin cifrar.

### T-36 · Consentimiento y política de privacidad · `LEG` · 🟠
- [ ] Texto de consentimiento de ubicación (Ley 29733; atención a menores de edad).
- [ ] Política de privacidad accesible en la app.
- **Hecho cuando:** el usuario acepta antes de activar la ubicación.

---

## SPRINT 4 – Panel web y mapa (🟡)

### T-40 · Panel web de administración · `WEB` · 🟡
Problema: `graph_admin_page` está en la app de estudiantes y `NavigationAutoInitializer` escribe en Firestore al arrancar.
- [ ] Web (Flutter Web o React) con Firebase Auth y rol admin.
- [ ] Gestión de salones, cursos, horarios y matrículas.
- [ ] Editor/validador del grafo del mapa y publicación de versiones (`graphVersion`).
- [ ] Reportes de asistencia con exportación CSV (función que genera el archivo).
- [ ] Quitar `graph_admin_page` y `NavigationAutoInitializer` de la app.
- **Hecho cuando:** los estudiantes no pueden alterar el mapa desde la app.

### T-41 · Grafo cacheado y versionado · `APP` · 🟡
Problema: el grafo se lee completo de Firestore (cientos de documentos) en cada arranque.
- [ ] Guardar el grafo como un documento/archivo versionado; la app lo descarga solo si cambia la versión y lo cachea en local.
- [ ] A\* con cola de prioridad en vez de recorrer el `openSet` entero.
- **Hecho cuando:** el mapa funciona sin red tras la primera carga y baja el número de lecturas.

### T-42 · Calibración y seguimiento de cámara · `APP` · 🟡
- [ ] Separar cálculo de rumbo y render; filtro complementario/Kalman.
- [ ] Calibración guiada (gesto en ocho) y aviso de baja precisión.
- [ ] Modo "norte arriba" de respaldo.
- [ ] Pausar sensores cuando no hay mapa abierto.
- **Hecho cuando:** la flecha no oscila parado y se corrige en una prueba de pasillo.

### T-43 · Mejoras de navegación · `APP` · 🟡
- [ ] Elegir motor de mapa principal (SVG o Mapbox) y documentarlo.
- [ ] Instrucciones paso a paso, tiempo estimado, ruta accesible, cambio de piso guiado.
- [ ] Búsqueda de salón con autocompletado y recientes.
- [ ] Optimizar `map_route_painter` (`RepaintBoundary`, `shouldRepaint`).
- **Hecho cuando:** se puede llegar a un salón siguiendo solo las instrucciones.

### T-44 · ~~Estado de baños en tiempo real~~ · NO APLICA (función eliminada)
- [ ] `snapshots()` con `updatedBy` y `updatedAt`.
- [ ] El estado vuelve a "desconocido" tras 30 minutos (función programada).
- [ ] Límite de frecuencia por usuario en reglas/función.
- **Hecho cuando:** un estado antiguo no se muestra como vigente.

---

## SPRINT 5 – Calidad de la app (🟡)

### T-50 · Gestión de estado y navegación · `APP` · 🟡
Problema: 64 `setState`; páginas de 670–710 líneas; `AppRoutes` solo conoce login y home.
- [ ] Riverpod o Bloc; sacar timers y lógica de `home_page`.
- [ ] `go_router` con guards de sesión.
- [ ] Dividir `map_canvas.dart`, `home_page.dart`, `course_card.dart`, `sensor_service.dart`, `text_styles.dart`.
- **Hecho cuando:** ningún archivo de UI supera ~300 líneas.

### T-51 · Errores y logging · `APP` · 🟡
Problema: 58 `print`, `catch (e) {}` silenciosos, `rethrow` sin transformar.
- [ ] Logger con niveles, desactivado en release.
- [ ] Repositorios devuelven `Failure`/`Result`.
- [ ] Inyectar `FirebaseAuth` y `Firestore` por constructor para poder testear.
- **Hecho cuando:** no quedan `print` ni `catch` vacíos.

### T-52 · UX y accesibilidad · `APP` · 🟡
Problema: 0 usos de `Semantics`.
- [ ] Estados de carga, vacío y error con reintento.
- [ ] `Semantics`, contraste, tamaños táctiles de 48 dp, texto escalable.
- [ ] Modo oscuro verificado; textos con `intl`/ARB.
- **Hecho cuando:** TalkBack recorre las pantallas principales.

### T-53 · Permisos de Android · `APP` · 🟡
Problema: `SCHEDULE_EXACT_ALARM` y `USE_EXACT_ALARM` redundantes; ubicación sin justificar.
- [ ] Dejar un solo permiso de alarma exacta según el caso.
- [ ] Pantalla explicativa antes de pedir permisos y manejo de "denegado permanente".
- [ ] Justificar `ACCESS_BACKGROUND_LOCATION` si se usa.
- **Hecho cuando:** pasa la revisión de permisos de Google Play.

---

## SPRINT 6 – Calidad y publicación (🟡)

### T-60 · Pruebas · `APP` + `FB` · 🟡
Problema: no existe `test/`.
- [ ] Unitarias: A\*, parsers SVG, casos de uso (con `fake_cloud_firestore`).
- [ ] Reglas de Firestore con el emulador.
- [ ] Tests de las Cloud Functions.
- [ ] Un flujo extremo a extremo de asistencia.
- **Hecho cuando:** cobertura mínima acordada y todo pasa en CI.

### T-61 · CI/CD · `OPS` · 🟡
- [ ] GitHub Actions: `flutter analyze`, `flutter test`, build de APK/AAB.
- [ ] Pipeline de Functions y reglas: lint, tests con emulador y despliegue a `dev`.
- [ ] Escaneo de secretos (gitleaks) en cada PR.
- **Hecho cuando:** un PR con una key o un test roto no se puede mergear.

### T-62 · Observabilidad y backups · `OPS` + `FB` · 🟡
- [ ] Crashlytics en la app y logs/alertas de Functions.
- [ ] Alertas de presupuesto y de cuota en Firebase.
- [ ] Exportación programada de Firestore a un bucket.
- **Hecho cuando:** un fallo aparece en el panel y se puede restaurar un backup.

### T-63 · Preparar la publicación · `OPS` + `APP` · 🟡
Problema: `com.example.flutter_application_1`, sin ofuscación.
- [ ] Id de paquete propio (y actualizar `google-services.json`).
- [ ] Firma de release y `--obfuscate --split-debug-info`.
- [ ] Ficha de Google Play y distribución interna.
- **Hecho cuando:** hay un AAB firmado instalable desde pruebas internas.

---

## SPRINT 7 – Piloto y adopción (🟡)

### T-70 · Piloto en un aula · todos · 🟡
- [ ] Alumnos y un docente usan la app durante 2 semanas.
- [ ] Métricas: precisión de asistencia, errores, batería, lecturas/escrituras de Firestore, satisfacción.
- [ ] Ajustar geocercas y reglas según los resultados.
- **Hecho cuando:** hay informe de resultados con mejoras priorizadas.

### T-71 · Propuesta a SENATI ⛔D2 · `LEG` · 🟡
- [ ] Documento con arquitectura, esquema, despliegue y operación.
- [ ] Privacidad, consentimiento, retención de datos y hosting.
- [ ] Integración con SSO o sistema académico, si aplican.
- **Hecho cuando:** SENATI recibe y valida la propuesta.

### T-72 · Revisar si Firebase sigue siendo suficiente · `FB` · 🟡
Firebase se reevalúa si ocurre alguno de estos casos:
- SENATI exige alojar los datos en su infraestructura.
- Se necesitan reportes complejos entre cursos, alumnos y semestres.
- Los costos de lecturas/escrituras se disparan al escalar más allá del aula.
- [ ] En ese caso, evaluar una base relacional detrás de Cloud Functions o una API, migrando solo asistencia e historial académico.
- **Hecho cuando:** hay decisión documentada con datos reales del piloto.

---

## Orden recomendado para arrancar ya
1. **Hoy:** T-01, T-02, T-06, T-07.
2. **Esta semana:** T-03, T-04, T-05 y decidir D1 (plan Blaze).
3. **Después:** T-10 a T-14, y en paralelo `APP` avanza T-24 y T-50.

## Resumen de vulnerabilidades y dónde se resuelven

| Severidad | Hallazgo | Tarea |
|---|---|---|
| Crítica | API key de Gemini hardcodeada | T-01, T-30 |
| Alta | Reglas de Firestore abiertas | T-03 |
| Alta | Asistencia falsificable e incorrecta | T-20 a T-23 |
| Alta | Búsqueda que descarga toda la colección y ubicación expuesta | T-33, T-34 |
| Media | Token de Mapbox hardcodeado | T-02 |
| Media | Esquema duplicado e inconsistente | T-10, T-31 |
| Media | Sin App Check | T-04 |
| Media | Siembra del grafo desde la app | T-14, T-40 |
| Media | Sesión sin cifrar | T-35 |
| Media | Permisos de Android | T-53 |
| Baja | Errores silenciados y `print` | T-51 |
| Baja | Id `com.example…`, sin ofuscación | T-63 |
| Baja | Código legado y sin tests | T-05, T-60 |

> Nota: el análisis es estático sobre el repositorio. No se revisaron las reglas desplegadas en Firebase, que pueden diferir de `firestore.rules`.
