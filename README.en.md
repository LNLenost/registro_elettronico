# Registro Elettronico — Classeviva fork

Open-source Flutter application for accessing Classeviva electronic school-register data.

This repository is a **fork of [`riccardocalligaro/registro_elettronico`](https://github.com/riccardocalligaro/registro_elettronico)**, maintained by [@lnlenost](https://github.com/LNLenost). The fork keeps the original project as the `upstream` remote and uses [`LNLenost/registro_elettronico`](https://github.com/LNLenost/registro_elettronico) for development, issues, and builds.

> Status: the original project uses Flutter 1.22.6 and pre-null-safety Dart. Modernisation and maintenance are ongoing.

## Features

- Classeviva data access;
- school agenda and calendar;
- grades, averages, and statistics;
- absences and late arrivals;
- completed lessons;
- circulars and bulletin board;
- teaching materials;
- custom events;
- multiple accounts;
- light and dark themes;
- agenda-event sharing;
- charts for school-performance trends;
- Classeviva web integration.

Available data depends on the school and account type.

## Requirements

- Flutter `1.22.6`;
- Dart compatible with Flutter 1.22.6;
- Android SDK for Android builds;
- Java compatible with the project’s Gradle toolchain.

[FVM](https://fvm.app/) is recommended for isolating the legacy Flutter version:

```bash
fvm install 1.22.6
fvm use 1.22.6
fvm flutter pub get
```

## Android build

Debug build:

```bash
fvm flutter build apk --debug
```

Release build:

```bash
fvm flutter build apk --release
```

The generated APK is normally placed in `build/app/outputs/flutter-apk/`.

## Classeviva API

The app uses publicly documented Classeviva endpoints and the service’s intended authentication flow. Never add credentials, tokens, or private keys to the source tree or APKs.

References:

- [Project API documentation](API_DOCS.md)
- [Classeviva Official Endpoints](https://github.com/michelangelomo/Classeviva-Official-Endpoints)
- [Unofficial Classeviva documentation](https://classeviva.readthedocs.io/it/latest/api.html)

## Development

Main structure:

- `lib/core/` — shared components and configuration;
- `lib/feature/authentication/` — authentication;
- `lib/feature/agenda/` — agenda and events;
- `lib/feature/grades/` — grades and averages;
- `lib/feature/absences/` — absences and late arrivals;
- `lib/feature/web/` — web integration;
- `android/` — Android project;
- `ios/` — iOS project.

To work on the fork:

```bash
git clone https://github.com/LNLenost/registro_elettronico.git
cd registro_elettronico
git remote add upstream https://github.com/riccardocalligaro/registro_elettronico.git
```

## Issues and contributions

- [Open an issue](https://github.com/LNLenost/registro_elettronico/issues/new)
- [Browse issues](https://github.com/LNLenost/registro_elettronico/issues)
- [Browse pull requests](https://github.com/LNLenost/registro_elettronico/pulls)

Before submitting changes, verify that dependencies and the build work with the specified Flutter version.

## License

See the `LICENSE` file in this repository.

## Italiano

La versione italiana, impostata come README principale, è disponibile in [`README.md`](README.md).
