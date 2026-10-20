# Portal Taller - Implementación y pruebas

Este documento está ordenado para seguir el flujo de trabajo de compilación, instalación y validación de la app.

## 1. Requisitos previos

- Docker y Docker Compose instalados.
- Dispositivo Android conectado en modo depuración.
- Permitir la transferencia de archivos y la depuración USB.
- Estar parado en la raíz del proyecto.

## 2. Entrar al entorno de desarrollo

Si necesitas trabajar dentro del contenedor de Flutter:

```bash
docker exec -it portal-taller-flutter bash
```

## 3. Generar APK de release

### Opción A: compilar directamente desde Docker

```bash
docker compose run --rm flutter flutter build apk --release
```

### Opción B: compilar dentro del contenedor

```bash
flutter build apk --release
```

La APK generada quedará en:

```bash
app/build/app/outputs/apk/release/app-release.apk
```

## 4. Instalar la app en el teléfono

Desde la raíz del proyecto, ejecuta:

```bash
adb install -r app/build/app/outputs/apk/release/app-release.apk
```

## 5. Probar la aplicación

1. Conecta el celular en modo depuración.
2. Verifica que el dispositivo aparezca en ADB:

```bash
adb devices
```

3. Instala la APK con el comando anterior.
4. Abre la app en el celular y valida el flujo de uso.

## 6. Desinstalar la app si es necesario

```bash
adb uninstall com.example.workspace
```

## 7. Solución a errores comunes

### Error: INSTALL_FAILED_UPDATE_INCOMPATIBLE

Si aparece este error:

```bash
Performing Streamed Install
adb: failed to install app/build/app/outputs/apk/release/app-release.apk: Failure [INSTALL_FAILED_UPDATE_INCOMPATIBLE: Existing package com.example.workspace signatures do not match newer version; ignoring!]
```

Puede resolverse desinstalando la versión anterior antes de reinstalar:

```bash
adb uninstall com.example.workspace
adb install -r app/build/app/outputs/apk/release/app-release.apk
```

Esto ocurre porque la firma de la nueva APK no coincide con la versión instalada anteriormente.
