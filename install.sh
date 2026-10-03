#!/usr/bin/env bash
set -euo pipefail

# Suppress debconf warnings in headless / Codespaces environments
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Project Parameters
PROJECT_DIR="${1:-new_datapack}"   # my_datapack/ already exists in this repo
DATAPACK_NAME="${2:-Template Pack}"
NAMESPACE="${3:-example}"
MINECRAFT_VERSION="${4:-21}"
PACK_FORMAT="${5:-48}"   # 48 = Minecraft 1.21 / 1.21.1

# --- Input validation (fail fast, before installing anything) ---
if [[ ! "$PROJECT_DIR" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo "Error: PROJECT_DIR must be a valid Dart package name (lowercase, digits, underscores; start with a letter)." >&2
    exit 1
fi
if [[ ! "$NAMESPACE" =~ ^[a-z0-9_.-]+$ ]]; then
    echo "Error: NAMESPACE must match [a-z0-9_.-]+ (no spaces, no uppercase)." >&2
    exit 1
fi
if [[ ! "$MINECRAFT_VERSION" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: MINECRAFT_VERSION must be a number like 21 or 20.4." >&2
    exit 1
fi
if [[ ! "$PACK_FORMAT" =~ ^[0-9]+$ ]]; then
    echo "Error: PACK_FORMAT must be an integer." >&2
    exit 1
fi
if [ -e "$PROJECT_DIR" ]; then
    echo "Error: '$PROJECT_DIR' already exists!" >&2
    exit 1
fi

# Escape backslashes / single quotes for use inside Dart '...' strings
DART_NAME="${DATAPACK_NAME//\\/\\\\}"
DART_NAME="${DART_NAME//\'/\\\'}"

echo "==> 1/4: Checking Dart SDK..."
# Inside the devcontainer Dart is already installed, so this block is skipped.
if ! command -v dart >/dev/null 2>&1 && [ ! -x /usr/lib/dart/bin/dart ]; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq apt-transport-https wget gnupg curl > /dev/null

    if [ ! -f /usr/share/keyrings/dart.gpg ]; then
        wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub \
            | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/dart.gpg
        echo 'deb [signed-by=/usr/share/keyrings/dart.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' \
            | sudo tee /etc/apt/sources.list.d/dart_stable.list > /dev/null
        sudo apt-get update -qq
    fi
    sudo apt-get install -y -qq dart > /dev/null
fi

# PATH Configuration
export PATH="$PATH:/usr/lib/dart/bin:$HOME/.pub-cache/bin"
if ! grep -q '\.pub-cache/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$PATH:/usr/lib/dart/bin:$HOME/.pub-cache/bin"' >> ~/.bashrc
fi
echo "==> Dart Version: $(dart --version 2>&1)"

echo "==> 2/4: Activating objd_cli global package..."
dart pub global activate objd_cli > /dev/null || echo "Warning: objd_cli activation failed (optional, continuing)."

echo "==> 3/4: Creating project '$PROJECT_DIR'..."
mkdir -p "$PROJECT_DIR/lib"
cd "$PROJECT_DIR"

cat <<EOF > pubspec.yaml
name: $PROJECT_DIR
description: A new objD datapack project.
version: 1.0.0
publish_to: none

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  objd: ^0.4.7
EOF

cat <<EOF > lib/main.dart
import 'package:objd/core.dart';

void main(List<String> args) {
  createProject(
    Project(
      name: '$DART_NAME',
      version: $MINECRAFT_VERSION,
      packFormat: $PACK_FORMAT,
      generate: Pack(
        name: '$NAMESPACE',
        load: File(
          'load',
          child: ForLoad(),
        ),
        main: File(
          'main',
          child: ForMain(),
        ),
      ),
    ),
    args,
  );
}

class ForLoad extends Widget {
  @override
  Widget generate(Context context) {
    return Log('$DART_NAME loaded successfully!');
  }
}

class ForMain extends Widget {
  @override
  Widget generate(Context context) {
    return Comment('Commands executing every tick (1/20s)');
  }
}
EOF

echo "==> 4/4: Fetching dependencies (dart pub get)..."
dart pub get

echo
echo "==> Test build (dart run lib/main.dart)..."
if dart run lib/main.dart; then
    echo "Build OK."
else
    echo "Warning: test build failed. If the error mentions 'packFormat', remove that line from lib/main.dart." >&2
fi

echo
echo "Setup completed!"
echo "-------------------------------------------------------"
echo "  cd $PROJECT_DIR"
echo "  dart run lib/main.dart"
echo "-------------------------------------------------------"
