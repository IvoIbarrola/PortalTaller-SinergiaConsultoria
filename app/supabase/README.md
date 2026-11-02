# Supabase - Portal Taller

## Estado inicial

- Esquema inicial: `supabase/migrations/001_initial_schema.sql`
- Cliente Flutter opcional: `lib/data/supabase_config.dart`
- `main.dart` inicializa Supabase cuando se proporcionan las variables de compilación.
- Si no se configuran las credenciales, la app inicia en modo demo local sin requerir internet.
- `AppState` consulta perfiles, siniestros, vehículos, talleres y mensajes desde Supabase.
- La pantalla de ingreso usa Supabase Auth (email y contraseña).

## Configurar el proyecto

1. Crear un proyecto en https://supabase.com/.
2. En el panel del proyecto, abrir **SQL Editor**.
3. Aplicar las migraciones en orden: `001_initial_schema.sql`, `002_seed_demo_data.sql`, `003_claim_management_demo_data.sql`, `004_seed_claim_management_examples.sql` y `005_authenticated_read_policies.sql`. Las migraciones `002` y `004` cargan ejemplos ficticios.
4. En **Project Settings / API** (o **Connect**, según la interfaz), obtener la Project URL y la clave pública **anon/publishable**.
5. No usar ni incluir nunca la clave `service_role` en Flutter ni en el repositorio.

Desde la carpeta `app`, ejecutar:

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU_CLAVE_PUBLICA
```

Para compilar el APK:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU_CLAVE_PUBLICA
```

Reemplazar los valores de ejemplo por los de tu proyecto. No subir credenciales personales ni claves privadas a Git.

## Tablas incluidas

- `profiles`: perfiles y roles de la aplicación, vinculados mediante `auth_user_id` a Supabase Auth.
- `workshops`: datos de talleres.
- `vehicles`: vehículos.
- `repair_cases`: siniestros, estado, progreso y taller asignado.
- `case_messages`: mensajes asociados a un siniestro.
- `case_photos`: metadatos de fotos; el archivo se almacena en el bucket privado `case-photos`.

## Seguridad y limitaciones actuales

La migración habilita Row Level Security (RLS) en todas las tablas y crea un bucket privado, pero deliberadamente **no agrega políticas de acceso permisivas**. Hasta implementar autenticación, asociar perfiles a usuarios autenticados y definir políticas de tablas y Storage, las consultas del cliente no podrán acceder a datos reales. No desactivar RLS para solucionar errores de permisos.

La demo local permite recorrer los perfiles de asegurado, taller y consultoría.
Los cambios de casos, progreso, estado, checklist, mensajes y novedades se
guardan en el almacenamiento privado del dispositivo. Las fotos de demostración
se copian al almacenamiento local de la app. Estos datos no se sincronizan con
Supabase ni entre dispositivos; `Reiniciar datos de demo` restaura los ejemplos.

La gestión local de vehículos y talleres, junto con las estadísticas y sus
filtros, también es exclusiva de la demo. No escribe en Supabase ni modifica
sus tablas o políticas.

La pantalla de Configuración guarda apariencia y personalización del perfil en
el dispositivo. Reportar un error abre un borrador de correo al destinatario
configurado en la app; el envío requiere confirmación manual y no incluye datos
de siniestros.

Antes de usar datos reales, la siguiente etapa debe implementar autenticación y políticas RLS para que cada asegurado vea solo sus casos, los talleres solo sus casos asignados y la consultora tenga permisos administrativos explícitos.
