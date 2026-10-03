# datapack-template-v2
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/tickwarden/datapack-template-v2?quickstart=1)

A minimal [objD](https://pub.dev/packages/objd) template for writing Minecraft: Java Edition data packs in Dart instead of hand-written `.mcfunction` files. Works out of the box in GitHub Codespaces.

## Repository layout

```
.
├── install.sh              # Scaffolds a brand-new objD project
├── .vscode/tasks.json      # VS Code build task (runs the generator)
├── my_datapack/            # Ready-to-use example project
│   ├── pubspec.yaml
│   └── lib/main.dart       # Pack definition (load + main functions)
├── LICENSE                 # Unlicense (public domain)
└── .gitignore
```

## Requirements

- [Dart SDK](https://dart.dev/get-dart) 3.0 or newer (objD 0.4.7 requires Dart 3)
- Linux/Debian-based environment for `install.sh` (Codespaces works). On other systems, install Dart manually and use the manual steps below.

## Quick start

```bash
cd my_datapack
dart pub get
dart run lib/main.dart
```

`dart run lib/main.dart` generates the data pack and **exits when done**. Run it again after every change to `lib/main.dart`.

> **Note:** You do not need `build_runner`. It only generates code for `objd_gen` annotations (`@Pck`, `@Fil`, ...), which this template does not use. `dart run build_runner watch` stays open forever and prints `wrote 0 outputs`; it does not build your data pack.

To remove everything objD generated, run:

```bash
dart run lib/main.dart --clean
```

## How `lib/main.dart` works

```dart
import 'package:objd/core.dart';

void main(List<String> args) {
  createProject(
    Project(
      name: 'example',          // output folder name
      version: 21,              // Minecraft version (21 = 1.21)
      generate: Pack(
        name: 'example',        // data pack namespace
        load: File('load', child: ForLoad()),   // runs on /reload
        main: File('main', child: ForMain()),   // runs every tick
      ),
    ),
    args,
  );
}
```

| Piece | Purpose |
| --- | --- |
| `Project` | Top-level container. Holds the output name, target Minecraft version and the pack to generate. |
| `Pack` | One data pack. Its `name` is the namespace, so it must be lowercase without spaces. |
| `File` | A `.mcfunction` file. `load` and `main` are registered automatically as the load and tick functions. |
| `Widget` | Reusable building block. Subclass it and return commands from `generate(...)`. |

`Log(...)` sends a chat message to all players (it does not write to the server console). `Comment(...)` writes a comment line into the function file.

## Creating a new project with `install.sh`

```bash
chmod +x install.sh
./install.sh [PROJECT_DIR] [DATAPACK_NAME] [NAMESPACE] [MINECRAFT_VERSION] [PACK_FORMAT]
```

| Argument | Default | Notes |
| --- | --- | --- |
| `PROJECT_DIR` | `my_datapack` | Must be a valid Dart package name (`[a-z][a-z0-9_]*`). Must not exist yet. |
| `DATAPACK_NAME` | `Template Pack` | Used for `Project.name` and the load message. |
| `NAMESPACE` | `example` | Lowercase letters, digits, `_`, `.`, `-`. |
| `MINECRAFT_VERSION` | `21` | Accepts decimals such as `20.4`. |
| `PACK_FORMAT` | `48` | `pack_format` for 1.21 / 1.21.1. |

The script installs the Dart SDK only if it is missing (inside the dev container it already is), activates `objd_cli`, creates the project, runs `dart pub get` and finishes with a test build. The default directory is `my_datapack` because `my_datapack/` already exists in this repository.

## Installing the data pack in Minecraft

Copy the generated folder (the one containing `pack.mcmeta`) into `<world>/datapacks/`, then run `/reload` in-game. On a successful load you should see the message from `ForLoad` in chat.

## Known limitations

- **Minecraft 1.21 folder names.** Starting with 1.21 the `functions/` folder was renamed to `function/` (and similarly for tag folders). objD 0.4.7 was released in late 2023 for 1.20.4, so it may still write `functions/`. After the first run, inspect `data/<namespace>/`. If you see `functions/` and your functions do not load in 1.21+, rename the folders or target 1.20.4 (`version: 20.4`).
- **Pack format.** objD derives `pack_format` from `version`. Check the generated `pack.mcmeta` and make sure it matches your Minecraft version.
- **Generated output is git-ignored** only for the `datapack/` folder (see `.gitignore`). Check where objD writes its output on your machine before committing.

## Resources

- [objD on pub.dev](https://pub.dev/packages/objd)
- [objD documentation](https://objd.stevertus.com/guide/)

## License

[Unlicense](LICENSE): public domain, use it for anything.
