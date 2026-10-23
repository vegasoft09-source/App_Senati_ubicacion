# Plan de tareas – App_ubicacion_senati

Un solo documento: vulnerabilidades detectadas + tareas para corregirlas y llevar la app a producción (SENATI).
Cada tarea tiene ID, responsable sugerido y criterio de "terminado". Las claves reales NO se copian aquí.

**Responsables:** `APP` = Flutter · `API` = backend y base de datos · `WEB` = panel admin · `OPS` = CI/CD, repo, publicación · `LEG` = privacidad y relación con SENATI

**Prioridad:** 🔴 hacer ya · 🟠 siguiente · 🟡 luego

## Decisiones tomadas
- Equipo de varias personas; demo en un aula; objetivo final: uso por SENATI; sin presupuesto (capas gratuitas).
- PostgreSQL + PostGIS (Neon o Supabase) como base principal; API propia en Docker; Firestore solo para tiempo real (baños, presencia); Firebase Auth y FCM por ahora; Gemini solo desde la API.

## Decisiones pendientes (bloquean tareas marcadas con ⛔)
- [ ] **D1** Lenguaje de la API: TypeScript (NestJS) o Python (FastAPI).
- [ ] **D2** Neon o Supabase.
- [ ] **D3** Dónde se aloja la API en la demo (Render, Railway, Cloud Run).
- [ ] **D4** Contacto en SENATI (SSO, hosting, privacidad).

---

## SPRINT 0 – Cerrar riesgos (🔴 empezar hoy, sin depender de decisiones)

### T-01 · Revocar y sacar la API key de Gemini · `APP` · 🔴
Problema (crítico): la key está hardcodeada en `lib/features/chatbot/data/data_sources/chatbot_service.dart:16`, en el historial de git y en el APK.
- [ ] Revocar la key actual en Google AI Studio y crear una nueva.
- [ ] Quitarla del código; leerla con `String.fromEnvironment('GEMINI_KEY')` y `--dart-define` (temporal hasta T-30).
- [ ] Restringir la nueva key por app/API y poner cuota baja.
- **Hecho cuando:** no hay ninguna key en el repo y el chatbot funciona con `--dart-define`.

### T-02 · Sacar y restringir el token de Mapbox · `APP` · 🔴
Problema: token `pk.` hardcodeado en `mapbox_map_page.dart:19` y se imprime parcialmente en `:69`.
- [ ] Moverlo a `--dart-define=MAPBOX_TOKEN`.
- [ ] Quitar el `print` del token.
- [ ] Restringirlo por paquete en Mapbox y rotarlo.
- **Hecho cuando:** `grep "pk\."` en `lib/` no devuelve nada.

### T-03 · Endurecer `firestore.rules` · `API` · 🔴
Problema (alto): cualquier usuario autenticado puede escribir en `mapas`, `salones` y `bathrooms`; hay una regla comodín de lectura global.
- [ ] `mapas` y `salones`: escritura solo con custom claim `admin == true`.
- [ ] `bathrooms`: permitir solo actualizar campos de estado, con tipos validados.
- [ ] Validar esquema en `usuarios`/`students` (`hasOnly`, tipos, rangos).
- [ ] Eliminar la regla comodín `match /{document=**}`.
- [ ] Pruebas con el emulador de Firestore.
- **Hecho cuando:** un usuario normal no puede escribir en `mapas`/`salones` y las pruebas pasan.

### T-04 · Activar Firebase App Check · `API` · 🔴
Problema: sin App Check, cualquier script o app ajena usa tu proyecto Firebase.
- [ ] Activar Play Integrity y exigirlo en Firestore y Auth.
- **Hecho cuando:** peticiones sin token de App Check son rechazadas.

### T-05 · Limpiar el repositorio · `OPS` · 🔴
Problema: `assets/lib_ext/` (44 archivos Dart) es una copia legada dentro de los assets; sin `test/`; carpetas sin uso.
- [ ] Borrar `assets/lib_ext/` (queda en el historial).
- [ ] Revisar `.gitignore` (`build/`, llaves, archivos locales).
- [ ] Eliminar o completar `features/notes` y `features/identification`.
- [ ] Decidir qué plataformas se mantienen (`linux`, `macos`, `windows`, `web`).
- **Hecho cuando:** el APK no incluye código legado y `flutter analyze` pasa.

### T-06 · Organizar el trabajo en equipo · `OPS` · 🔴
- [ ] Proteger `main` y exigir PR con al menos 1 revisión.
- [ ] Convención de ramas (`feat/…`, `fix/…`) y de commits.
- [ ] `README` real: requisitos, cómo ejecutar, variables `--dart-define`.
- [ ] Plantillas de PR e issues; crear estas tareas como issues/tablero.
- **Hecho cuando:** nadie puede pushear a `main` directamente.

### T-07 · Decidir si se limpia el historial de git · `OPS` · 🔴
- [ ] Decidir con el equipo si se ejecuta `git filter-repo` para borrar las keys antiguas (la rotación de T-01/T-02 es obligatoria igual).
- **Hecho cuando:** hay decisión documentada y, si aplica, el historial está limpio.

---

## SPRINT 1 – Modelo de datos y contrato (🟠)

### T-10 · Decidir D1, D2, D3 · `API` · 🟠
- [ ] Reunión de equipo y registrar la decisión en este documento.

### T-11 · Diseñar el esquema de PostgreSQL ⛔D2 · `API` · 🟠
Problema (medio): hoy hay `usuarios` y `students` duplicados, campos mezclados (`IdEstudiante`, `NameEstudent`, `lat`, `lon`) y fechas como string.
- [ ] Tablas: `users`, `roles`, `students`, `teachers`, `courses`, `enrollments`, `schedules`, `rooms`, `floors`, `buildings`, `attendance_records`, `friendships`, `bathrooms`, `bathroom_status`, `map_nodes`, `map_edges`, `map_versions`, `audit_log`.
- [ ] Una convención única de nombres e idioma.
- [ ] Geocercas del campus como polígonos PostGIS.
- [ ] Timestamps de servidor.
- [ ] Revisión del esquema en equipo.
- **Hecho cuando:** el esquema está aprobado y versionado en el repo.

### T-12 · Repositorio y entorno del backend ⛔D1 ⛔D3 · `API` · 🟠
- [ ] Proyecto base con Docker y `docker-compose` (API + Postgres).
- [ ] Migraciones versionadas.
- [ ] Entornos `dev`, `staging`, `prod` por variables de entorno.
- **Hecho cuando:** `docker compose up` levanta API y base de datos.

### T-13 · Contrato OpenAPI · `API` + `APP` · 🟠
- [ ] Definir endpoints: auth, estudiantes, cursos/horarios, asistencia, amigos, baños, mapas, chatbot.
- [ ] Versionado `/v1`, formato de errores y paginación.
- [ ] Mocks de la API para que la app avance sin esperar al backend.
- **Hecho cuando:** el contrato está aprobado por ambos lados.

### T-14 · Scripts de datos semilla · `API` · 🟠
- [ ] Mover `initialize_salones.dart` (529 líneas) e `initialize_bathrooms.dart` a scripts de administración.
- [ ] Importación de salones, cursos y horarios desde CSV.
- **Hecho cuando:** la app no escribe datos semilla en producción.

---

## SPRINT 2 – Asistencia confiable (🟠)

### T-20 · Endpoint de asistencia en servidor · `API` · 🟠
Problema (alto): `validate_attendance_use_case.dart` devuelve `present` para todos los cursos salvo uno hardcodeado ("REDES DE COMPUTADORAS", 7:15 PM), y todo se calcula en el cliente: GPS falso u hora manipulada bastan.
- [ ] El cliente envía posición y curso; el servidor decide con hora del servidor y geocerca PostGIS.
- [ ] Reglas por curso en datos (`graceMinutes`, `lateMinutes`).
- [ ] Estados: `present`, `late`, `absent`, `justified`.
- [ ] Rate limiting por usuario.
- **Hecho cuando:** modificar la hora del móvil no cambia el resultado.

### T-21 · Anti-spoofing de ubicación · `API` + `APP` · 🟠
- [ ] Detectar `Position.isMocked` y enviarlo al servidor.
- [ ] Rechazar saltos de velocidad imposibles y precisión baja.
- **Hecho cuando:** una app de GPS falso es detectada y registrada.

### T-22 · Historial persistente de asistencia · `API` · 🟠
Problema: `courseFirstEntryTime` vive en memoria y se pierde al cerrar la app.
- [ ] Guardar cada registro con estado, hora y ubicación validada, más auditoría.
- **Hecho cuando:** cerrar la app no pierde la asistencia del día.

### T-23 · Migrar la app a la nueva asistencia · `APP` · 🟠
- [ ] Reemplazar `ValidateAttendanceUseCase` por llamadas a la API.
- [ ] Borrar el código muerto `_validateNormalAttendance` y el caso especial de Redes.
- [ ] Pantalla de historial desde el servidor.
- [ ] Cola de eventos sin conexión que se envía al reconectar.
- **Hecho cuando:** la asistencia en la app coincide con la del servidor.

### T-24 · Ubicación y batería · `APP` · 🟠
Problema: `Timer.periodic` cada 3 s para GPS más otros dos timers en `home_page`; escribe a Firestore cada ciclo.
- [ ] Usar `getPositionStream` con `distanceFilter` y precisión media.
- [ ] Enviar al servidor solo en cambios de estado o cada N minutos.
- [ ] Servicio en primer plano solo si se necesita segundo plano.
- **Hecho cuando:** el consumo de batería baja y las escrituras por usuario caen.

---

## SPRINT 3 – Usuarios, roles y privacidad (🟠)

### T-30 · Mover el chatbot a la API ⛔D1 · `API` + `APP` · 🟠
- [ ] Endpoint `/v1/chat` que valida el usuario y limita peticiones.
- [ ] Prompt de sistema con contexto del campus (salones, horarios, reglas) y límite de longitud.
- [ ] La app deja de llamar a Gemini directamente.
- **Hecho cuando:** no hay key de Gemini en la app.

### T-31 · Unificar `usuarios` y `students` · `API` + `APP` · 🟠
- [ ] Un solo modelo de usuario; migrar datos existentes.
- [ ] Actualizar registro, amigos y GPS al nuevo modelo.
- **Hecho cuando:** solo existe una colección/tabla de usuarios.

### T-32 · Roles y cuentas institucionales ⛔D4 · `API` · 🟠
- [ ] Roles: estudiante, docente, administrador (custom claims).
- [ ] Registro solo con correo institucional o invitación.
- [ ] Verificación de correo y recuperación de contraseña.
- **Hecho cuando:** un correo ajeno no puede registrarse.

### T-33 · Búsqueda de estudiantes segura · `API` + `APP` · 🟠
Problema (alto): `searchStudentByName` descarga toda la colección `usuarios` y filtra en el dispositivo.
- [ ] Consulta con límite y prefijo (`nameLower`) o endpoint de búsqueda.
- **Hecho cuando:** el cliente nunca recibe más de N resultados.

### T-34 · Privacidad de ubicación · `API` + `APP` + `LEG` · 🟠
Problema (alto): `lat`/`lon` en el mismo documento que los datos personales.
- [ ] Separar presencia de datos personales.
- [ ] Compartir con amigos solo dentro/fuera, no coordenadas, salvo consentimiento.
- [ ] Amistades con solicitud y aceptación.
- [ ] Política de retención y borrado de ubicaciones antiguas.
- **Hecho cuando:** un amigo no puede ver tus coordenadas exactas.

### T-35 · Sesión segura en el cliente · `APP` · 🟠
- [ ] Usar `flutter_secure_storage` para tokens (`tokenKey`, `userKey`).
- [ ] Verificar que el QR de login no contiene credenciales reutilizables.
- **Hecho cuando:** nada sensible está en almacenamiento sin cifrar.

### T-36 · Consentimiento y política de privacidad · `LEG` · 🟠
- [ ] Texto de consentimiento de ubicación (Ley 29733; atención a menores de edad).
- [ ] Política de privacidad accesible en la app.
- **Hecho cuando:** el usuario acepta antes de activar la ubicación.

---

## SPRINT 4 – Panel web y mapa (🟡)

### T-40 · Panel web de administración ⛔D1 · `WEB` · 🟡
Problema: `graph_admin_page` está dentro de la app de estudiantes y `NavigationAutoInitializer` escribe en Firestore al arrancar la app.
- [ ] Login con rol admin.
- [ ] Gestión de salones, cursos, horarios y matrículas.
- [ ] Editor/validador del grafo del mapa y publicación de versiones (`graphVersion`).
- [ ] Reportes de asistencia con exportación CSV/PDF.
- [ ] Quitar `graph_admin_page` y `NavigationAutoInitializer` de la app.
- **Hecho cuando:** los estudiantes no pueden alterar el mapa desde la app.

### T-41 · Grafo cacheado y versionado · `APP` + `API` · 🟡
- [ ] La app descarga el grafo solo si cambia la versión y lo guarda en local.
- [ ] A\* con cola de prioridad en vez de recorrer el `openSet` entero.
- **Hecho cuando:** el mapa funciona sin red tras la primera carga.

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

### T-44 · Estado de baños en tiempo real · `API` + `APP` · 🟡
- [ ] `snapshots()` con `updatedBy` y `updatedAt`.
- [ ] El estado vuelve a "desconocido" tras 30 minutos.
- [ ] Límite de frecuencia por usuario.
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
- [ ] Inyectar `FirebaseAuth`, `Firestore` y clientes HTTP por constructor.
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

### T-60 · Pruebas · `APP` + `API` · 🟡
Problema: no existe `test/`.
- [ ] Unitarias: A\*, parsers SVG, casos de uso.
- [ ] API: unitarias e integración con Postgres en contenedor.
- [ ] Reglas de Firestore con emulador.
- [ ] Un flujo extremo a extremo de asistencia.
- **Hecho cuando:** cobertura mínima acordada y todo pasa en CI.

### T-61 · CI/CD ⛔D3 · `OPS` · 🟡
- [ ] GitHub Actions: `flutter analyze`, `flutter test`, build de APK/AAB.
- [ ] Pipeline del backend: lint, tests, imagen Docker y despliegue.
- [ ] Escaneo de secretos (gitleaks) en cada PR.
- **Hecho cuando:** un PR con una key o un test roto no se puede mergear.

### T-62 · Observabilidad y backups · `OPS` · 🟡
- [ ] Crashlytics o Sentry en app y API.
- [ ] Logs estructurados y alertas básicas.
- [ ] Backups programados de Postgres y Firestore.
- **Hecho cuando:** un fallo en producción aparece en el panel y se puede restaurar un backup.

### T-63 · Preparar la publicación · `OPS` + `APP` · 🟡
Problema: `com.example.flutter_application_1`, sin flavors ni ofuscación.
- [ ] Id de paquete propio.
- [ ] Flavors `dev`/`prod` con proyectos Firebase distintos.
- [ ] Firma de release y `--obfuscate --split-debug-info`.
- [ ] Ficha de Google Play y distribución interna.
- **Hecho cuando:** hay un AAB firmado instalable desde pruebas internas.

---

## SPRINT 7 – Piloto y adopción (🟡)

### T-70 · Piloto en un aula · todos · 🟡
- [ ] Alumnos y un docente usan la app durante 2 semanas.
- [ ] Métricas: precisión de asistencia, errores, batería, satisfacción.
- [ ] Ajustar geocercas y reglas según los resultados.
- **Hecho cuando:** hay informe de resultados con mejoras priorizadas.

### T-71 · Propuesta a SENATI ⛔D4 · `LEG` · 🟡
- [ ] Documento con arquitectura, esquema, despliegue y operación.
- [ ] Privacidad, consentimiento, retención de datos y hosting.
- [ ] Plan de migración de la API y la base de datos a su infraestructura.
- [ ] Integración con SSO o sistema académico, si aplican.
- **Hecho cuando:** SENATI recibe y valida la propuesta.

---

## Orden recomendado para arrancar ya
1. **Hoy:** T-01, T-02, T-06, T-07 (rápidas y sin dependencias).
2. **Esta semana:** T-03, T-04, T-05 y la reunión T-10 para cerrar D1–D3.
3. **Después:** T-11 a T-14 en paralelo (API/base de datos) mientras `APP` avanza T-24 y T-50 usando los mocks de T-13.

## Resumen de vulnerabilidades y dónde se resuelven

| Severidad | Hallazgo | Tarea |
|---|---|---|
| Crítica | API key de Gemini hardcodeada | T-01, T-30 |
| Alta | Reglas de Firestore abiertas | T-03 |
| Alta | Asistencia falsificable e incorrecta | T-20 a T-23 |
| Alta | Búsqueda que descarga toda la colección y ubicación expuesta | T-33, T-34 |
| Media | Token de Mapbox hardcodeado | T-02 |
| Media | Esquema duplicado e inconsistente | T-11, T-31 |
| Media | Sin App Check | T-04 |
| Media | Siembra del grafo desde la app | T-14, T-40 |
| Media | Sesión sin cifrar | T-35 |
| Media | Permisos de Android | T-53 |
| Baja | Errores silenciados y `print` | T-51 |
| Baja | Id `com.example…`, sin ofuscación | T-63 |
| Baja | Código legado y sin tests | T-05, T-60 |

> Nota: el análisis es estático sobre el repositorio. No se revisaron las reglas desplegadas en Firebase, que pueden diferir de `firestore.rules`.
