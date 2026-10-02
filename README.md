# Generar APK

docker compose run --rm flutter flutter build apk --release

## O entrar en el contenedor

docker exec -it portal-taller-flutter bash

### Y ejecutar

flutter build apk --release

# Instalar en el teléfono

adb install -r app/build/app/outputs/apk/release/app-release.apk
