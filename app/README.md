# Portal Taller · Sinergia Siniestros

Aplicación piloto Flutter para el seguimiento de siniestros y reparaciones por
parte de asegurados, talleres y consultoría. La identidad visual toma como
referencia la paleta azul marino, turquesa y coral del sitio de Grupo Sinergia.

## Demo local para presentación

La app funciona sin conexión a Supabase cuando no se pasan las variables
`SUPABASE_URL` y `SUPABASE_ANON_KEY`. Desde la pantalla inicial se puede
ingresar con los perfiles ficticios de asegurado, taller o consultoría.

La demo permite recorrer casos, asignar talleres, cambiar estados y avances,
crear casos, enviar mensajes, registrar fotos, completar checklist y cargar
novedades. Los cambios se guardan en el almacenamiento privado de la app en
ese dispositivo; no se sincronizan con Supabase ni con otros teléfonos.
`Reiniciar datos de demo` restaura los ejemplos originales. Las fotos se
guardan localmente y también se eliminan al borrarlas desde la app.

El perfil de Consultoría también permite registrar y editar vehículos
(asegurado, versión, chasis/VIN, kilometraje y observaciones), administrar
talleres y desactivarlos sin borrar su historial. El panel de estadísticas
resume casos por estado y taller, avance promedio y próximas entregas; admite
filtros por fecha, estado, taller y búsqueda de siniestro, patente o asegurado.
Estas funciones de administración son exclusivas de la demo local.

Todos los perfiles tienen una pantalla de Configuración con apariencia clara,
oscura o del sistema; nombre y datos de contacto personalizables en el
dispositivo; y un formulario para reportar errores. El reporte abre un borrador
dirigido a `ivo18ibarrola@gmail.com` en la aplicación de correo instalada. No se
envía hasta que el usuario lo confirme. No se adjuntan datos de siniestros.

Para generar una APK de presentación desde este directorio:

```sh
flutter pub get
flutter build apk --release
```

La APK se genera en `build/app/outputs/flutter-apk/app-release.apk`.

## Conectar Supabase

Para usar el acceso remoto en lugar de la demo, ejecutar pasando la URL del
proyecto y la clave pública `anon`/publishable:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://TU-PROYECTO.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=TU_CLAVE_PUBLICA
```

No incluir claves `service_role` en la aplicación.

## Validar

```sh
flutter analyze
flutter test
```

Los estilos globales se centralizan en `lib/theme/app_theme.dart`. Los datos
locales de ejemplo se mantienen en `lib/data/demo_data.dart` y el estado
persistido en `lib/state/app_state.dart`.
