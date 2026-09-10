<div align="center">
  <img src="assets/icons/launcher_icon.png" alt="Registro Elettronico" width="96">
  <h1>Registro Elettronico</h1>
  <p>Un client Flutter moderno per consultare il registro eletteonico Classeviva.</p>

  <p>
    <a href="https://github.com/LNLenost/registro_elettronico"><img src="https://img.shields.io/badge/repository-LNLenost%2Fregistro__elettronico-181717?logo=github" alt="Repository GitHub"></a>
    <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-2.5.3-02569B?logo=flutter&logoColor=white" alt="Flutter 2.5.3"></a>
    <a href="LICENSE.md"><img src="https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-blue" alt="Licenza CC BY-NC-SA 4.0"></a>
  </p>
</div>

> **Nota:** questa è un’applicazione non ufficiale e non è affiliata, approvata o sponsorizzata da Spaggiari o ClasseViva.

## Screenshot

<p align="center">
  <img src="docs/screenshots/custom-themes.jpg" alt="Schermate di Registro Elettronico con temi personalizzabili" width="520">
</p>

## Cos’è

**Registro Elettronico** è un client alternativo per Classeviva personalizzabile al 100%, con funzionalità aggiuntive.

Il progetto nasce come fork aggiornato di [Registro Elettronico di Riccardo Calligaro](https://github.com/riccardocalligaro/registro_elettronico), con interventi di manutenzione, compatibilità, localizzazione e nuove funzioni.


## Funzionalità

- autenticazione Classeviva e gestione dei profili;
- voti, materie e andamento scolastico;
- statistiche sui voti e sull’anno scolastico;
- assenze, ritardi e uscite, con filtro per intervallo di date;
- agenda ed eventi personalizzati;
- lezioni svolte e orario calcolato;
- note e materiali didattici;
- circolari nella Bacheca, con:
  - caricamento nativo e fallback web autenticato;
  - ricerca testuale;
  - filtro per circolari lette/non lette;
  - filtro per categoria;
  - filtro per circolari attive/scadute;
- documenti e scrutini disponibili sull’account;
- pagina **Sostituzioni** collegabile a SostituzioniDocenti o MyProf;
- apertura del **Libretto Web** Classeviva dalla sezione Assenze;
- temi personalizzabili e modalità chiara/scura;
- interfaccia in italiano e inglese, con lingua iniziale basata sul dispositivo.

La disponibilità dei dati dipende dal profilo, dal ruolo dell’utente e dai moduli attivati dalla scuola.

## Requisiti

- Flutter **2.5.3**;
- Dart compatibile con Flutter 2.5.3;
- Java 11 per la build Android;
- Android SDK e un dispositivo Android oppure un emulatore.

La pipeline GitHub Actions esegue i test mirati e produce APK debug e release usando Flutter 2.5.3.

## Avvio locale

```bash
git clone https://github.com/LNLenost/registro_elettronico.git
cd registro_elettronico
flutter pub get
flutter run
```

Per eseguire i test disponibili:

```bash
flutter test test/noticeboard_filter_test.dart
flutter test test/absences_filter_test.dart
```

Per creare un APK di debug:

```bash
flutter build apk --debug
```

La build release firmata viene verificata nella [pipeline Android](https://github.com/LNLenost/registro_elettronico/actions/workflows/android-build.yml). Le chiavi di firma non sono incluse nel repository.

## Struttura del progetto

```text
lib/
├── core/                 # infrastruttura condivisa, rete, temi e localizzazione
├── feature/
│   ├── authentication/  # login e profili
│   ├── absences/        # assenze e ritardi
│   ├── agenda/          # agenda ed eventi
│   ├── didactics/       # materiali didattici
│   ├── grades/          # voti e periodi
│   ├── lessons/         # lezioni
│   ├── noticeboard/     # circolari
│   ├── scrutini/        # documenti e scrutini
│   ├── stats/            # statistiche
│   └── substitutions/   # Sostituzioni
├── utils/               # costanti e utilità
└── main.dart

test/                    # test mirati delle funzioni locali
assets/                  # icone, font e risorse grafiche
lang/                    # traduzioni italiano/inglese
```

## Stato del progetto

Il progetto è in manutenzione attiva. Le funzioni già presenti vengono mantenute con modifiche mirate e verifiche tramite test e GitHub Actions.

### In valutazione

Le seguenti funzioni ClasseViva richiedono ancora un contratto API di scrittura verificato o un flusso web autorizzato prima di poter essere implementate correttamente:

- giustificazione delle assenze;
- adesione e risposta alle circolari;
- upload dei compiti;
- colloqui e sportello;
- recuperi;
- documenti storici.

Non vengono inseriti endpoint, metodi HTTP o payload ipotetici.

## Contribuire

Bug report, proposte e pull request sono benvenuti:

- [Apri una issue](https://github.com/LNLenost/registro_elettronico/issues);
- [proponi una modifica con una pull request](https://github.com/LNLenost/registro_elettronico/pulls).

Quando segnali un problema, indica dispositivo, versione Android/iOS, versione dell’app e passaggi per riprodurlo. **Non includere password, token, cookie o altri dati personali.**

## Licenza

Il progetto è distribuito secondo la [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International](LICENSE.md).

## Crediti

- Progetto originale: [Riccardo Calligaro](https://github.com/riccardocalligaro);
- manutenzione del fork: [Niccolò Salerno](https://github.com/LNLenost);
- backend e servizi dati: ClasseViva/Spaggiari, secondo le condizioni d’uso dei rispettivi servizi.
