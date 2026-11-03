# datapack-template-v2

A Dart/objD Minecraft Java datapack template with an `objd_gui` chest-GUI
example. The **checked-in example**, not the separate scaffold defaults,
currently sets `version: 20`, `packFormat: 15` and a description naming
Minecraft **1.20.1**. The output and compatibility of the dependencies have
not been independently verified in Minecraft.

> **World safety:** `SetupChestGui` generates an armor-stand marker and a
> `SetBlock` command for a chest at the execution position. Running the
> generated setup function can replace an existing block and alter a world.
> Use a backed-up disposable world and inspect generated commands first.
> Do not use the example as evidence that arbitrary GUI code is safe.

## Repository layout

| Path | Purpose |
| --- | --- |
| [`my_datapack/lib/main.dart`](my_datapack/lib/main.dart) | Checked-in `Project`, functions, scoreboard, showcase and GUI example. |
| [`my_datapack/pubspec.yaml`](my_datapack/pubspec.yaml) | Dart SDK range and objD/objd_gui dependencies. |
| [`install.sh`](install.sh) | Separate project scaffold with system and home-directory side effects. |
| [`.vscode/tasks.json`](.vscode/tasks.json) | Pub Get, generator, analyzer and ZIP tasks. |
| [`.devcontainer/`](.devcontainer/) | Dart/devcontainer image and automatic post-create commands. |
| [`.github/workflows/build.yml`](.github/workflows/build.yml) | GitHub Actions build, artifact and tag-release configuration. |

## Requirements and dependency caveat

The example declares Dart `>=3.0.0 <4.0.0`, `objd: ^0.4.7` and
`objd_gui: ^0.2.0`. The pubspec comments that `objd_gui` 0.2.0 declares an SDK
constraint below 3.0.0 and uses a `dependency_overrides` entry. An override is
not a compatibility guarantee: dependency resolution, analysis, generation
and the target game version must be tested together. `pubspec.lock` is ignored,
so a later resolution can differ from an earlier one.

The devcontainer takes Dart from `dart:3` and copies it into the universal
container image. Its post-create command may add an `origin` remote if missing,
sets global Git `push.autoSetupRemote` to `true`, fetches Dart dependencies and
attempts global `objd_cli` activation. These are environment changes and
network operations; inspect them before starting the container. The Codespaces
badge is a convenience link, not a guarantee of available quota or a working
build.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/tickwarden/datapack-template-v2?quickstart=1)

## Using the checked-in example

After reviewing the code and dependency sources, the project documents this
flow for an isolated development environment:

```sh
cd my_datapack
dart pub get
dart run lib/main.dart
```

The entry point delegates to objD's `createProject` for normal arguments. The
project specifies `target: './build/'`, namespace `example`, `packFormat: 15`
and a `Template Pack` name. Confirm the actual generated paths and
`pack.mcmeta` before copying anything into a world. The old `--clean` command
is passed to the generator; its deletion scope has not been verified here, so
do not run it against valuable files.

For the two explicit ZIP branches in `main.dart`:

```sh
dart run lib/main.dart --export-zip  # requests template_pack.zip
dart run lib/main.dart --prod        # requests Template Pack.zip
```

They call `getAllFiles` and `saveAsZip`; review the library's output behavior
and use a fresh disposable directory so existing files are not at risk. The
checked-in VS Code task named `objD Watch` actually invokes the one-shot Dart
entry point; it does not explicitly start a watcher. The `Zip Datapack` task
assumes `my_datapack/Template Pack`, which may not match the configured
`./build/` target: inspect the actual output before relying on that task.
`build_runner watch` is not used by the checked-in entry point.

## What the generated pack is intended to do

- `load`: emits a load message, initializes `config` and `counter`
  scoreboards with `Scoreboard.prefix = 'tp_'`, and includes join/rejoin
  messages.
- `main`: advances a per-player counter, emits a message at 200 ticks and
  evaluates the GUI module at armor stands tagged `tp_gui`.
- `welcome`, `showcase/loops` and `showcase/math`: demonstrate text, tags,
  looping and scoreboard operations. They change or report state when run.
- `setup_gui`: requests an invisible marker armor stand and a chest at the
  execution position, then reports the GUI setup. The chest GUI example
  contains greeting and counter-reset actions.

These descriptions follow the Dart source; the exact emitted `.mcfunction`
files and their in-game behavior were not independently tested. In particular,
review selector behavior, block changes, generated objectives and any library
side effects before installing. Preserve your world before `/reload` or
function calls.

## Separate `install.sh` scaffold

The script accepts `PROJECT_DIR`, `DATAPACK_NAME`, `NAMESPACE`,
`MINECRAFT_VERSION` and `PACK_FORMAT`, with defaults `my_datapack`, `Template
Pack`, `example`, `21` and `48`. It validates the directory, namespace, numeric
version and format and refuses an already existing project directory. Since
`my_datapack/` is already tracked, its default invocation in this checkout
stops at that check.

**Important discrepancy:** although arguments 2–5 are parsed and some are
validated, the current heredoc writes hard-coded `Template Pack`, `example`,
`21` and `48` into the new `lib/main.dart`; the caller's corresponding values
are not substituted. The scaffold is a separate simple example, not a copy of
the checked-in 1.20.1 GUI project.

If run after that check, the script may use `sudo apt-get`, configure the Dart
APT source and keyring, append to `~/.bashrc`, globally activate `objd_cli`,
create files, fetch packages and run a test build. It warns and continues if
that final test build fails. Inspect the script and use a fresh isolated
machine before deciding to run it; this README change did not run it.

## CI and verification limits

The Actions workflow runs on pull requests and pushes to `main`/`master`, tag
pushes matching `v*`, and manual dispatch. Its build job resolves Dart
packages, runs `dart analyze --fatal-infos`, invokes `--prod`, locates a ZIP and
uploads an artifact. A separate release job is conditional on a `v*` tag and
can create a GitHub release; the workflow declares `contents: write`. Those
are workflow definitions, not a claim that any particular run succeeded.

For this documentation change the source was inspected, but Dart, dependency
resolution, VS Code tasks, the scaffold, GitHub Actions and Minecraft were not
run locally. Confirm folder names, pack metadata and generated output for the
specific Minecraft version rather than relying on an untested automatic
conversion between versions.

## Resources and license

- [objD package](https://pub.dev/packages/objd) and
  [objD documentation](https://objd.stevertus.com/guide/).
- [Unlicense](LICENSE); refer to the file for its public-domain dedication and
  warranty disclaimer.
