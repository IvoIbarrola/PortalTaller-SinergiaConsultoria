# Supabase - Portal Taller

## Estado inicial

- Esquema inicial: `supabase/migrations/001_initial_schema.sql`
- Cliente Flutter opcional: `lib/data/supabase_config.dart`
- `main.dart` inicializa Supabase cuando se proporcionan las variables de compilación.
- Si no se configuran las credenciales, la app sigue iniciando en modo demo/local.

## Configurar el proyecto

1. Crear un proyecto en https://supabase.com/.
2. En el panel del proyecto, abrir **SQL Editor**.
3. Copiar y ejecutar el contenido de `app/supabase/migrations/001_initial_schema.sql`.
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

- `profiles`: perfiles y roles de la aplicación; preparado para vincularse a Supabase Auth en una etapa posterior.
- `workshops`: datos de talleres.
- `vehicles`: vehículos.
- `repair_cases`: siniestros, estado, progreso y taller asignado.
- `case_messages`: mensajes asociados a un siniestro.
- `case_photos`: metadatos de fotos; el archivo se almacena en el bucket privado `case-photos`.

## Seguridad y limitaciones actuales

La migración habilita Row Level Security (RLS) en todas las tablas y crea un bucket privado, pero deliberadamente **no agrega políticas de acceso permisivas**. Hasta implementar autenticación, asociar perfiles a usuarios autenticados y definir políticas de tablas y Storage, las consultas del cliente no podrán acceder a datos reales. No desactivar RLS para solucionar errores de permisos.

La autenticación real está pospuesta según lo acordado. Por eso, esta primera entrega solo deja preparada la estructura y la inicialización del cliente; todavía no reemplaza el `AppState` en memoria, no importa los datos de ejemplo y no persiste mensajes ni fotos. La app conserva el modo demo/local si no se pasan credenciales.

Antes de usar datos reales, la siguiente etapa debe implementar autenticación y políticas RLS para que cada asegurado vea solo sus casos, los talleres solo sus casos asignados y la consultora tenga permisos administrativos explícitos.
