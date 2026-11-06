FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# -------------------------
# Versiones / rutas
# -------------------------
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV FLUTTER_HOME=/opt/flutter

ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/36.0.0:${PATH}"

# -------------------------
# Dependencias del sistema
# -------------------------
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# Flutter
# -------------------------
RUN git clone --depth 1 --branch stable \
    https://github.com/flutter/flutter.git \
    ${FLUTTER_HOME}

RUN flutter precache --android

# -------------------------
# Android SDK
# -------------------------
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools

RUN wget -q \
    https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip \
    -O /tmp/cmdline-tools.zip

RUN unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools \
       ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

# -------------------------
# Android SDK packages
# -------------------------
RUN yes | sdkmanager --licenses > /dev/null || true

RUN sdkmanager \
    "platform-tools" \
    "platforms;android-36" \
    "build-tools;36.0.0"

# -------------------------
# Flutter configuration
# -------------------------
RUN flutter config --no-analytics

# -------------------------
# Gradle Wrapper cache
# -------------------------
ENV GRADLE_USER_HOME=/root/.gradle

RUN mkdir -p \
    /root/.gradle/wrapper/dists/gradle-9.3.1-all/a3a9c1a4364f10b24bbcd345dd24da3c

COPY .gradle-download/gradle-9.3.1-all.zip \
    /root/.gradle/wrapper/dists/gradle-9.3.1-all/a3a9c1a4364f10b24bbcd345dd24da3c/

RUN flutter doctor

# -------------------------
# Proyecto
# -------------------------
WORKDIR /workspace

CMD ["bash"]