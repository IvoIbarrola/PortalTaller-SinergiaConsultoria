# Generar APK

docker compose run --rm flutter flutter build apk --release

# Instalar en el teléfono

adb install -r app/build/app/outputs/apk/release/app-release.apk
