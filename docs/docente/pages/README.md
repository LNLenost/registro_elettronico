# Pagine dell'area docente (struttura anonimizzata)

Copie delle pagine web dell'area docente ClasseViva usate per scrivere i
parser in `lib/feature/docente/data/`. Contengono solo la **struttura**:

- ogni testo è sostituito da segnaposto (lettere → `a`, cifre → `0`), tranne
  poche etichette dell'interfaccia (titoli, pulsanti);
- ogni testo con la forma di un nome di persona è mascherato anche se
  compare in un'intestazione (alcune griglie hanno gli studenti come colonne);
- ogni valore di attributo è mascherato, tranne quelli puramente strutturali
  (`class`, `colspan`, …); gli `id` mantengono la forma con le cifre azzerate;
- negli URL restano solo i nomi dei parametri; sequenze di 3+ cifre azzerate;
- script, stili, commenti HTML e voci dei menu a tendina sono rimossi;
- ogni tabella mantiene al massimo 3 righe per tipo di riga;
- nomi di studenti, docenti, scuola e codici identificativi sono stati
  verificati assenti prima della pubblicazione.

Le pagine sono state ottenute in sola lettura (solo navigazioni GET, nessun
modulo inviato). Per l'elenco completo di pagine, parametri, moduli e link
vedi `../TREE.md`.
