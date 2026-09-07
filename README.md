# Registro Elettronico — fork di Classeviva

Applicazione Flutter open source per consultare il registro elettronico Classeviva.

Questa repository è un **fork di [`riccardocalligaro/registro_elettronico`](https://github.com/riccardocalligaro/registro_elettronico)**, mantenuto da [@lnlenost](https://github.com/LNLenost). Il fork conserva il riferimento al progetto originale come remote `upstream` e usa il repository [`LNLenost/registro_elettronico`](https://github.com/LNLenost/registro_elettronico) come riferimento per sviluppo, issue e build.

> Stato: il progetto originale usa Flutter 1.22.6 e Dart senza null safety. Il lavoro di aggiornamento e manutenzione è in corso.

## Funzioni

- accesso ai dati Classeviva;
- agenda e calendario scolastico;
- voti, medie e statistiche;
- assenze e ritardi;
- lezioni svolte;
- circolari e bacheca;
- materiali didattici;
- eventi personalizzati;
- gestione multi-account;
- temi chiaro e scuro;
- condivisione degli eventi dell’agenda;
- visualizzazioni grafiche dell’andamento scolastico;
- accesso alla versione web di Classeviva.

Le funzioni effettivamente disponibili possono dipendere dai dati restituiti dalla scuola e dal tipo di account.

## Requisiti

- Flutter `1.22.6`;
- Dart compatibile con Flutter 1.22.6;
- Android SDK per la build Android;
- Java compatibile con la toolchain Gradle del progetto.

È consigliato usare [FVM](https://fvm.app/) per isolare la versione legacy di Flutter:

```bash
fvm install 1.22.6
fvm use 1.22.6
fvm flutter pub get
```

## Build Android

Build debug:

```bash
fvm flutter build apk --debug
```

Build release:

```bash
fvm flutter build apk --release
```

L’APK generato si trova normalmente in `build/app/outputs/flutter-apk/`.

## API Classeviva

L’app utilizza gli endpoint Classeviva pubblicamente documentati e il flusso di autenticazione previsto dal servizio. Non inserire credenziali, token o chiavi private nei sorgenti o negli APK.

Riferimenti utili:

- [Documentazione API del progetto](API_DOCS.md)
- [Classeviva Official Endpoints](https://github.com/michelangelomo/Classeviva-Official-Endpoints)
- [Documentazione Classeviva non ufficiale](https://classeviva.readthedocs.io/it/latest/api.html)

## Sviluppo

Struttura principale:

- `lib/core/` — configurazione e componenti condivisi;
- `lib/feature/authentication/` — autenticazione;
- `lib/feature/agenda/` — agenda ed eventi;
- `lib/feature/grades/` — voti e medie;
- `lib/feature/absences/` — assenze e ritardi;
- `lib/feature/web/` — integrazione web;
- `android/` — progetto Android;
- `ios/` — progetto iOS.

Per lavorare sul fork:

```bash
git clone https://github.com/LNLenost/registro_elettronico.git
cd registro_elettronico
git remote add upstream https://github.com/riccardocalligaro/registro_elettronico.git
```

## Segnalazioni e contributi

- [Apri una issue](https://github.com/LNLenost/registro_elettronico/issues/new)
- [Consulta le issue](https://github.com/LNLenost/registro_elettronico/issues)
- [Consulta le pull request](https://github.com/LNLenost/registro_elettronico/pulls)

Prima di inviare una modifica, verifica almeno che dipendenze e build siano eseguibili con la versione Flutter indicata.

## Licenza

Consulta il file `LICENSE` presente nella repository.

## English

La versione inglese è disponibile in [`README.en.md`](README.en.md).
