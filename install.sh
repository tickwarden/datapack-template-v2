#!/usr/bin/env bash
set -euo pipefail

# 1. Environment Variables and Parameters
PROJECT_DIR="${1:-my_datapack}"
DATAPACK_NAME="${2:-Example Pack}"
NAMESPACE="${3:-example}"
MINECRAFT_VERSION="${4:-19}"
TEMPLATE="${5:-basic}"

echo "==> 1/4: Installing Dart SDK..."
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -qq
sudo apt-get install -y -qq apt-transport-https wget gnupg curl

if [ ! -f /usr/share/keyrings/dart.gpg ]; then
    wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
    echo 'deb [signed-by=/usr/share/keyrings/dart.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list > /dev/null
    sudo apt-get update -qq
fi

sudo apt-get install -y -qq dart

# 2. PATH Configuration
export PATH="$PATH:/usr/lib/dart/bin:$HOME/.pub-cache/bin"

if ! grep -q '\.pub-cache/bin' ~/.bashrc; then
    echo 'export PATH="$PATH:/usr/lib/dart/bin:$HOME/.pub-cache/bin"' >> ~/.bashrc
fi

echo "==> Dart Version: $(dart --version 2>&1)"

# 3. Global Activation of objD CLI
echo "==> 2/4: Activating objectd_cli..."
dart pub global activate objectd_cli > /dev/null

# 4. Project Creation (Non-interactive)
echo "==> 3/4: Creating project '$PROJECT_DIR'..."
if [ -d "$PROJECT_DIR" ]; then
    echo "Error: Directory '$PROJECT_DIR' already exists!"
    exit 1
fi

# Note: Pass flags based on CLI version
objectd new "$PROJECT_DIR" \
  --name "$DATAPACK_NAME" \
  --namespace "$NAMESPACE" \
  --template "$TEMPLATE" \
  --target "$MINECRAFT_VERSION" || \
dart pub global run objectd_cli new "$PROJECT_DIR"

# 5. Fetching Dependencies
echo "==> 4/4: Fetching project dependencies..."
cd "$PROJECT_DIR"
dart pub get

echo -e "\n✅ Setup completed!"
echo "You can now navigate to the project directory and start build_runner:"
echo "cd $PROJECT_DIR && dart run build_runner watch"