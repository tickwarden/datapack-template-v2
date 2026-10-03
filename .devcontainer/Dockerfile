# Dart SDK comes from the official Dart image (no third-party devcontainer feature,
# no apt repo, no manual checksum handling).
# objD ^0.4.7 needs Dart 3.x and the template's pubspec caps the SDK at <4.0.0,
# so stay on the 3.x line. If the tag does not exist, use dart:stable.
ARG DART_VERSION=3
FROM dart:${DART_VERSION} AS dart

FROM mcr.microsoft.com/devcontainers/base:ubuntu
COPY --from=dart /usr/lib/dart /usr/lib/dart
ENV PATH="${PATH}:/usr/lib/dart/bin:/home/vscode/.pub-cache/bin"
