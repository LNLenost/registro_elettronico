# Area docente nell'app: stato delle schermate

Area in **sola lettura**: l'app legge le pagine del registro web con la
sessione ottenuta dal login SPID/CIE e non invia moduli, firme, voti,
assenze o conferme di lettura.

Legenda:

- **verificata**: provata su dispositivo con un account docente reale e dati
  reali;
- **sperimentale**: parser dedotto dalla struttura della pagina
  (vedi `pages/`), perché l'account usato per la mappatura non aveva dati da
  mostrare. Nell'app è etichettata "Sperimentale · non verificata", con un
  avviso e il pulsante per aprire la pagina web e confrontare;
- **interfaccia ufficiale**: prodotto Spaggiari separato (single sign-on),
  aperto nella sua interfaccia web.

## Accesso

| Percorso | Stato |
| --- | --- |
| CIE con app CieID sullo stesso telefono (flusso IPZS con `startActivityForResult`) | verificata |
| SPID (gestori diversi da CIE) | sperimentale: le pagine del gestore restano nella WebView; l'app del gestore si apre solo dai suoi pulsanti "apri l'app" e il login riprende quando si torna all'app. Nessun gestore SPID provato |

## Schermate

| Schermata | Pagina web | Stato |
| --- | --- | --- |
| Home, agenda personale | `acc/agenda.php`, `agenda.fn.php?action=get_events` | verificata |
| Bacheca | `sif/bacheca_personale.php` (`get_comunicazioni`) | verificata (le circolari non vengono aperte, per non registrare la lettura) |
| Le mie classi | `cvv/gioprof_selezione.php` | verificata |
| Tutte le classi, corsi extracurricolari | `cvv/selezione_classi.php`, `cvv/selezione_gruppi.php` | verificata |
| Registro di classe | `cvv/regclasse.php` | verificata |
| Assenze | `cvv/regassenze.php?granular=m` | verificata |
| Agenda di classe | `cvv/agenda.php?ope=get_events` | verificata |
| Giornale del professore | `cvv/gioprof.php` | verificata |
| Voti | `cvv/regvoti.php` | verificata (struttura); senza voti reali sull'account |
| Colloqui | `cvv/gioprof_colloqui.php` | sperimentale (mesi verificati, slot dedotti) |
| Note disciplinari | `cvv/gioprof_note.php` | sperimentale (griglia studenti × giorni; il testo della nota resta nella pagina web) |
| Orario docente | `cvv/orario_docente.php?periodo=&ope=docente` | sperimentale (tabella `#table_orario` vuota sulla scuola mappata) |
| Didattica | `cvv/didattica.php` | sperimentale (pagina vuota; cartelle e contenuti dedotti dagli attributi id) |
| Adozioni libri di testo | `ldt/libri_classi.php` | sperimentale (classi dai link con `classe_id`, libri dalle righe con ISBN) |
| Didattica a distanza (DAD) | `cvv/didattica_distanza.php?classe_id=` | sperimentale (griglia giorni × studenti e mesi verificati; come è marcato un giorno di DAD è dedotto, sulla classe mappata non ce n'erano) |
| Scrutinio online: classi e materie | `sol/gioprof_scrutinionline.php` | verificata |
| Scrutinio online: voti proposti | `cvv/regvoti_proposti.php` | sperimentale (periodi, componenti, medie e assenze verificati; i voti proposti erano vuoti) |
| Impostazioni | app | solo le voci valide per il docente (tema, colore, lingua, informazioni) |
| Ver.Di: riunioni personali | `vrd/riunioni_pers.php` | sperimentale (intestazione e filtri verificati; righe dedotte, nessuna riunione) |
| Libro firma | `sdg/firma_anywhere.php` | sperimentale (filtri e stato "nessun documento" verificati; documenti dedotti; non si firma dall'app) |
| PLS: compilazione | `pdp/selezione_classi.php` → `lista_studenti_pfi.php` | classi verificate; studenti della classe sperimentale (vuota) |
| PLS: statistiche | `cmp/statistiche.php` | sperimentale (elenco studenti verificato; i grafici sono disegnati dallo script della pagina e non vengono letti) |
| PLS: portfolio | `pdp/portfolio_studente.php` | sperimentale (pagina vuota) |
| Votazioni (Eligo) | `home/eligoauth.php` | verificata come stato: l'account non è registrato ("203 - Utente non ancora creato nella piattaforma Quorum") |
| Moduli on-line | `ber/compilazione_modulo.php` | verificata (elenco per sezione; la compilazione resta sul web) |
| Richieste/Comunicazioni | `ngs/richieste.exec.php` (`ope=get`) | sperimentale (lettura dell'elenco; nessuna richiesta sull'account; non si crea nulla) |
| Applicazioni | `home/menu_scuoladelfuturo.php` | verificata (menu); "Amministrazione e personale" e "Formazione" sono prodotti con login proprio e restano nella loro interfaccia web |

Chi ha un account con questi dati può verificare una schermata sperimentale
confrontandola con la pagina web (pulsante nell'avviso) e segnalare le
differenze; i test in `test/docente_*_test.dart` descrivono la struttura
attesa da ciascun parser.
