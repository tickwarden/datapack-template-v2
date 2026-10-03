#!/usr/bin/env bash
set -euo pipefail

# Suppress debconf warnings in headless / Codespaces environments
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Project Parameters
PROJECT_DIR="${1:-my_datapack}"
DATAPACK_NAME="${2:-Example Pack}"
NAMESPACE="${3:-example}"
MINECRAFT_VERSION="${4:-21}"

echo "==> 1/5: Checking Dart SDK system dependencies..."

sudo apt-get update -qq
sudo apt-get install -y -qq apt-transport-https wget gnupg curl > /dev/null

if [ ! -f /usr/share/keyrings/dart.gpg ]; then
    wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
    echo 'deb [signed-by=/usr/share/keyrings/dart.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list > /dev/null
    sudo apt-get update -qq
fi

sudo apt-get install -y -qq dart > /dev/null

# PATH Configuration
export PATH="$PATH:/usr/lib/dart/bin:$HOME/.pub-cache/bin"
if ! grep -q '\.pub-cache/bin' ~/.bashrc; then
    echo 'export PATH="$PATH:/usr/lib/dart/bin:$HOME/.pub-cache/bin"' >> ~/.bashrc
fi

echo "==> Dart Version: $(dart --version 2>&1)"

# Global CLI Activation
echo "==> 2/5: Activating objd_cli global package..."
dart pub global activate objd_cli > /dev/null

# Project Directory Setup
echo "==> 3/5: Setting up project structure for '$PROJECT_DIR'..."
if [ -d "$PROJECT_DIR" ]; then
    echo "Error: Directory '$PROJECT_DIR' already exists!"
    exit 1
fi

mkdir -p "$PROJECT_DIR/lib"
mkdir -p "$PROJECT_DIR/.vscode"
cd "$PROJECT_DIR"

# Generate pubspec.yaml (including build_runner and objd dependencies)
cat <<EOF > pubspec.yaml
name: $PROJECT_DIR
description: A new objD datapack project.
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  objd: ^0.5.0

dev_dependencies:
  build_runner: ^2.4.0
EOF

# Template lib/main.dart Structure
cat <<EOF > lib/main.dart
import 'package:objd/core.dart';

void main(List<String> args) {
  createProject(
    DataPack(
      name: '$DATAPACK_NAME',
      main: File(
        'main',
        child: ForMain(),
      ),
      load: File(
        'load',
        child: ForLoad(),
      ),
      version: $MINECRAFT_VERSION,
    ),
    args,
  );
}

class ForLoad extends Widget {
  @override
  Widget generate(Context context) {
    return Log('$DATAPACK_NAME loaded successfully!');
  }
}

class ForMain extends Widget {
  @override
  Widget generate(Context context) {
    return Comment('Commands executing every tick (1/20s)');
  }
}
EOF

# VS Code Automatic Build Task (.vscode/tasks.json)
cat <<EOF > .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "objD Watch",
      "type": "shell",
      "command": "dart run build_runner watch --delete-conflicting-outputs",
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      }
    }
  ]
}
EOF

# Fetch Dependencies
echo "==> 4/5: Fetching project dependencies (dart pub get)..."
dart pub get

echo -e "\n✅ Setup completed!"
echo "-------------------------------------------------------"
echo "You can now navigate into the project and start coding:"
echo "  cd $PROJECT_DIR"
echo "  dart run build_runner watch --delete-conflicting-outputs"
echo "-------------------------------------------------------"