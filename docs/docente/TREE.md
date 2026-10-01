# Mappa dell'area docente ClasseViva (web)

Generata esplorando in sola lettura (solo navigazioni GET, nessun invio di
moduli) l'area docente di `web.spaggiari.eu` con una sessione SPID/CIE.
Serve a chi sviluppa senza un account docente: struttura delle pagine,
parametri, moduli e chiamate. Nessun dato personale: vedi `pages/README.md`.

Pagine visitate: 71.

## `/home/app/default/menu_classevivadocente.php` — Registri e didattica multimediale
- link: `/home/app/default/menu_classevivadocente.php`, `/acc/app/default/me.php`, `/acc/app/default/agenda.php`, `/acc/app/default/documentazione.php`, `/cvv/app/default/didattica_distanza.php`, `/ldt/app/default/libri_classi.php`, `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/selezione_classi.php`, `/cvv/app/default/selezione_gruppi.php`(corsoextra), `/cvv/app/default/didattica.php`, `/sif/app/default/bacheca_personale.php`, `/home/app/default/menu_scrutinionlinedocente.php`, `/cvv/app/default/gioprof_colloqui.php`, `/home/app/default/menu_verdi.php`, `/ber/app/default/compilazione_modulo.php`, `/home/app/default/menu_competenze.php`, `/home/app/default/menu_scuoladelfuturo.php`, `/cvv/`, `/cvv`, `/sol`, `/pdp/app/default/lista_studenti_pfi.php`, `/cmp/app/default/statistiche.php`, `/pdp/app/default/portfolio_studente.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/home/app/default/xasapi.php`, `/home/app/default/eligoauth.php`, `/ngs/app/default/richieste_utente_new.php`, `/f4s_web/learnin`, `/img/supremo.exe`, `/tic`, `/sdg/app/default/firma_anywhere.php`, `/ngs/`, `/ngs_pew/`, `/ngs_vew/`, `/ngs_com/`, `/ngs_mag/`, `/ngs_inv/`, `/ngs_rik/`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/acc/app/default/me.php` — Profilo
- modulo `POST /acc/app/default/me.fn.php`: `act`, `imagebase64`
- chiamate negli script: `me.xhr.php`, `me.fn.php`
- link: `/cvv`, `/acc/app/default/me.php`, `/acc/app/default/documentazione.php`(fs)
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`

## `/acc/app/default/agenda.php` — Agenda personale del docente
- modulo `POST /acc/app/default/agenda.fn.php`: `action`, `user`
- modulo `GET /acc/app/default/agenda.php`: `action`, `evento_id`, `nota_1`, `evento_data`, `all_day`, `time_start`, `time_end`, `nota_2`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/me.php`, `/acc/app/default/documentazione.php`(prodotto,cerca), `/cvv/app/default/regclasse.php`(classe_id,data_start)
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/img/document/privacy_spag_071021.pdf`

## `/acc/app/default/documentazione.php` — Crea ticket di assistenza
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`, `/acc/app/default/me.php`, `/acc/app/default/crea_ticket.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`

## `/cvv/app/default/didattica_distanza.php` — Gestione didattica a distanza
- chiamate negli script: `../../../tic/app/default/selezione_classi.php`, `didattica_distanza.php`, `didattica_distanza_io.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/didattica_distanza_sottogruppo.php`(classe_id), `/cvv/app/default/didattica_distanza.php`(classe_id,data_start), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regdidattica.php`(vista), `/cvv/app/default/gioprof_colloqui.php`, `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/ldt/app/default/libri_classi.php` — Lista Classi
- modulo `GET /ldt/app/default/libri_classi.php`: `cerca`, `id_scuola`, `anno_scol`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/me.php`, `/acc/app/default/documentazione.php`(ref)
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`

## `/cvv/app/default/gioprof_selezione.php` — Le mie classi
- modulo `GET /cvv/app/default/gioprof_selezione.php`: `cerca`
- modulo `GET /cvv/app/default/gioprof_selezione.php`: —
- chiamate negli script: `gioprof_selezione.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/orario_docente.php`, `/cvv/app/default/dirigente_alunno.php`, `/cvv/app/default/selezione_gruppi.php`, `/cvv/app/default/selezione_classi.php`, `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regclasse.php`(classe_id,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,gruppo_id), `/cvv/app/default/regwifi.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,materia,ope,codocenza,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/disposizione.php`, `/cvv/app/default/regdidattica.php`(vista), `/cvv/app/default/gioprof_colloqui.php`, `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/selezione_classi.php` — Selezione classi
- modulo `GET /cvv/app/default/selezione_classi.php`: `cerca`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/orario_docente.php`, `/cvv/app/default/selezione_gruppi.php`(corsoextra), `/cvv/app/default/selezione_classi.php`, `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regclasse.php`(classe_id,quad), `/cvv/app/default/disposizione.php`, `/cvv/app/default/regdidattica.php`(vista), `/cvv/app/default/gioprof_colloqui.php`, `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`, `/alw/app/default/riepilogo_deleghe.php`

## `/cvv/app/default/selezione_gruppi.php` — Selezione Corsi
Parametri: `corsoextra`
- modulo `GET /cvv/app/default/selezione_gruppi.php`: `corsoextra`, `cerca`
- chiamate negli script: `gestione_gruppi.php`, `classificazioni.php`, `classificazioniio.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/selezione_gruppi.php`(corsoextra), `/cvv/app/default/selezione_classi.php`, `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regclasse.php`(corsoextra,gruppo_id), `/cvv/app/default/regdidattica.php`(vista), `/cvv/app/default/gioprof_colloqui.php`, `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/didattica.php` — Didattica multimediale
- modulo `GET /cvv/app/default/didattica.php`: `cerca`
- modulo `GET /cvv/app/default/didattica.php`: `a`, `module_name`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/didattica_docenti.php`(classe_id,gruppo_id), `/cvv/app/default/regdidattica_compito.php`(vista,classe_id,gruppo_id), `/cvv/app/default/quiz.php`, `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regdidattica.php`(vista), `/cvv/app/default/gioprof_colloqui.php`, `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/sif/app/default/bacheca_personale.php` — Bacheca
- modulo `POST /sif/app/default/bacheca_personale.php`: `action`, `relazione_id`
- modulo `POST /sif/app/default/bacheca_personale.php`: `action`, `relazione_id`
- modulo `POST /sif/app/default/bacheca_personale.php`: `action`, `relazione_id`
- modulo `POST /sif/app/default/bacheca_personale.php`: `action`, `relazione_id`, `testo_risposta`
- modulo `POST /sif/app/default/bacheca_personale.php`: `action`, `relazione_id`, `file_risposta`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/home/app/default/menu_webinfoschool.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`, `/scp/app/default/bacheca_ministeriale.php`, `/home/app/default/xasapi.php`

## `/home/app/default/menu_scrutinionlinedocente.php` — Lo Scrutinio on-line
- link: `/home/app/default/menu_scrutinionlinedocente.php`, `/acc/app/default/me.php`, `/sol/app/default/gioprof_scrutinionline.php`, `/home/app/default/menu_webinfoschool.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/home/app/default/xasapi.php`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/cvv/app/default/gioprof_colloqui.php` — Colloqui con la famiglia
- chiamate negli script: `.php`, `gioprof_colloqui.php`, `colloquio_live.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/gioprof_colloqui.php`(autore_id), `/cvv/app/default/docenti_colloqui_generali.php`(autore_id), `/cvv/app/default/gioprof_sportello.php`, `/cvv/app/default/regdidattica.php`(vista), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/home/app/default/menu_verdi.php` — Verbali Digitali
- link: `/home/app/default/menu_verdi.php`, `/acc/app/default/me.php`, `/acc/app/default/documentazione.php`, `/home/app/default/menu_webinfoschool.php`, `/cvv/`, `/cvv`, `/sol`, `/home/app/default/menu_competenze.php`, `/pdp/app/default/lista_studenti_pfi.php`, `/cmp/app/default/statistiche.php`, `/pdp/app/default/portfolio_studente.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/vrd/app/default/riunioni_pers.php`, `/sdg/app/default/firma_anywhere.php`, `/img/supremo.exe`, `/tic`, `/ngs/`, `/ngs_pew/`, `/ngs_vew/`, `/ngs_com/`, `/ngs_mag/`, `/ngs_inv/`, `/ngs_rik/`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/ber/app/default/compilazione_modulo.php` — Moduli on-line
- modulo `POST /home/app/default/login.php`: `custcode`, `login`, `password`
- modulo `POST /home/app/default/login.php`: `login`, `password`
- modulo `POST /ber/app/default/login.php`: `badge_ident`
- modulo `POST /ber/app/default/login.php`: —
- modulo `GET /ber/app/default/compilazione_modulo.php`: `a`, `sede_codice`, `target`, `cerca`
- modulo `GET /ber/app/default/compilazione_modulo.php`: —
- modulo `GET /ber/app/default/compilazione_modulo.php`: —
- modulo `GET /ber/app/default/compilazione_modulo.php`: `mod_ass`
- modulo `GET /ber/app/default/compilazione_modulo.php`: `a`, `id`, `email_value`
- link: `/ber/`, `/ber/app/default/compilazione_modulo.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/CUSTOM/policy/canali_tematici/privacy.html`, `/home/app/default/logout.php`, `/sso/app/default/me.php`, `/sso/app/default/sam.php`

## `/home/app/default/menu_competenze.php` — (senza titolo)
- link: `/home/app/default/menu_competenze.php`, `/acc/app/default/me.php`, `/pdp/app/default/lista_studenti_pfi.php`, `/acc/app/default/documentazione.php`, `/cmp/app/default/statistiche.php`, `/pdp/app/default/portfolio_studente.php`(stampa), `/home/app/default/menu_scuoladelfuturo.php`, `/cvv/`, `/cvv`, `/sol`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/sdg/app/default/firma_anywhere.php`, `/img/supremo.exe`, `/tic`, `/ngs/`, `/ngs_pew/`, `/ngs_vew/`, `/ngs_com/`, `/ngs_mag/`, `/ngs_inv/`, `/ngs_rik/`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/home/app/default/menu_scuoladelfuturo.php` — Applicazioni Gruppo Spaggiari Parma
- link: `/home/app/default/menu_webinfoschool.php`, `/acc/app/default/me.php`, `/home/app/default/menu_classeviva.php`, `/home/app/default/menu_competenze.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/ngs/`, `/f4s_web/`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/cvv/` — Registri e didattica multimediale
- link: `/home/app/default/menu_classevivadocente.php`, `/acc/app/default/me.php`, `/acc/app/default/agenda.php`, `/acc/app/default/documentazione.php`, `/cvv/app/default/didattica_distanza.php`, `/ldt/app/default/libri_classi.php`, `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/selezione_classi.php`, `/cvv/app/default/selezione_gruppi.php`(corsoextra), `/cvv/app/default/didattica.php`, `/sif/app/default/bacheca_personale.php`, `/home/app/default/menu_scrutinionlinedocente.php`, `/cvv/app/default/gioprof_colloqui.php`, `/home/app/default/menu_verdi.php`, `/ber/app/default/compilazione_modulo.php`, `/home/app/default/menu_competenze.php`, `/home/app/default/menu_scuoladelfuturo.php`, `/cvv/`, `/cvv`, `/sol`, `/pdp/app/default/lista_studenti_pfi.php`, `/cmp/app/default/statistiche.php`, `/pdp/app/default/portfolio_studente.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/home/app/default/xasapi.php`, `/home/app/default/eligoauth.php`, `/ngs/app/default/richieste_utente_new.php`, `/f4s_web/learnin`, `/img/supremo.exe`, `/tic`, `/sdg/app/default/firma_anywhere.php`, `/ngs/`, `/ngs_pew/`, `/ngs_vew/`, `/ngs_com/`, `/ngs_mag/`, `/ngs_inv/`, `/ngs_rik/`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/cvv` — Registri e didattica multimediale
- link: `/home/app/default/menu_classevivadocente.php`, `/acc/app/default/me.php`, `/acc/app/default/agenda.php`, `/acc/app/default/documentazione.php`, `/cvv/app/default/didattica_distanza.php`, `/ldt/app/default/libri_classi.php`, `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/selezione_classi.php`, `/cvv/app/default/selezione_gruppi.php`(corsoextra), `/cvv/app/default/didattica.php`, `/sif/app/default/bacheca_personale.php`, `/home/app/default/menu_scrutinionlinedocente.php`, `/cvv/app/default/gioprof_colloqui.php`, `/home/app/default/menu_verdi.php`, `/ber/app/default/compilazione_modulo.php`, `/home/app/default/menu_competenze.php`, `/home/app/default/menu_scuoladelfuturo.php`, `/cvv/`, `/cvv`, `/sol`, `/pdp/app/default/lista_studenti_pfi.php`, `/cmp/app/default/statistiche.php`, `/pdp/app/default/portfolio_studente.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/home/app/default/xasapi.php`, `/home/app/default/eligoauth.php`, `/ngs/app/default/richieste_utente_new.php`, `/f4s_web/learnin`, `/img/supremo.exe`, `/tic`, `/sdg/app/default/firma_anywhere.php`, `/ngs/`, `/ngs_pew/`, `/ngs_vew/`, `/ngs_com/`, `/ngs_mag/`, `/ngs_inv/`, `/ngs_rik/`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/sol` — Lo Scrutinio on-line
- link: `/home/app/default/menu_scrutinionlinedocente.php`, `/acc/app/default/me.php`, `/sol/app/default/gioprof_scrutinionline.php`, `/home/app/default/menu_webinfoschool.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/home/app/default/xasapi.php`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/pdp/app/default/lista_studenti_pfi.php` — (senza titolo)
- modulo `GET /pdp/app/default/selezione_classi.php`: `cerca`
- link: `/home/app/default/menu_competenze.php`, `/acc/app/default/me.php`, `/pdp/app/default/lista_studenti_pfi.php`(classe_id,stampa)
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`

## `/cmp/app/default/statistiche.php` — Statistiche competenze
- link: `/home/app/default/menu_competenze.php`, `/acc/app/default/me.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`

## `/pdp/app/default/portfolio_studente.php` — Consulta
- modulo `GET /pdp/app/default/portfolio_studente.php`: `cerca`, `studente_id`, `stampa`
- chiamate negli script: `lista_studenti_pfi.php`, `/sdg/app/default/firma_anywhere.php`, `portfolio_studente.php`
- link: `/home/app/default/menu_competenze.php`, `/acc/app/default/me.php`, `/pdp/app/default/lista_studenti_pfi.php`(classe_id)
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`

## `/home/app/default/menu_classeviva.php` — Registri e didattica multimediale
- link: `/home/app/default/menu_classevivadocente.php`, `/acc/app/default/me.php`, `/acc/app/default/agenda.php`, `/acc/app/default/documentazione.php`, `/cvv/app/default/didattica_distanza.php`, `/ldt/app/default/libri_classi.php`, `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/selezione_classi.php`, `/cvv/app/default/selezione_gruppi.php`(corsoextra), `/cvv/app/default/didattica.php`, `/sif/app/default/bacheca_personale.php`, `/home/app/default/menu_scrutinionlinedocente.php`, `/cvv/app/default/gioprof_colloqui.php`, `/home/app/default/menu_verdi.php`, `/ber/app/default/compilazione_modulo.php`, `/home/app/default/menu_competenze.php`, `/home/app/default/menu_scuoladelfuturo.php`, `/cvv/`, `/cvv`, `/sol`, `/pdp/app/default/lista_studenti_pfi.php`, `/cmp/app/default/statistiche.php`, `/pdp/app/default/portfolio_studente.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/home/app/default/xasapi.php`, `/home/app/default/eligoauth.php`, `/ngs/app/default/richieste_utente_new.php`, `/f4s_web/learnin`, `/img/supremo.exe`, `/tic`, `/sdg/app/default/firma_anywhere.php`, `/ngs/`, `/ngs_pew/`, `/ngs_vew/`, `/ngs_com/`, `/ngs_mag/`, `/ngs_inv/`, `/ngs_rik/`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/cvv/app/default/regclasse.php` — Registro di classe
Parametri: `classe_id`, `data_start`
- modulo `GET /cvv/app/default/regclasse.php`: `check_studente[]`
- modulo `POST /cvv/app/default/regclasse_io.php`: `action`, `classe_id`, `data_start`, `supplenza`, `conteggioassenze`, `firmaparziale`, `materia`, `annualita`, `unita`, `tipo_attivita`, `ora_posizione`, `numero_ore`, `uda_firma`, `fase_firma`, `id_progetto_set`, `peso_ora`, `text_nota`, `output`
- chiamate negli script: `regclasse_io.php`, `regclasse_cambiaorapos.php`, `regclasse_cancella_firma.php`, `regclasse_conpresenza.php`, `ck_sess_connect.php`, `gioprof.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/agenda.php`(classe_id,gruppo_id,view), `/cvv/app/default/regassenze.php`(granular,classe_id,iniziali,data_start,gruppo_id), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id,iniziali), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,ope,codocenza,gruppo_id,materia), `/cvv/app/default/regvoti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id), `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`, `/cvv-interactive/app/default/whiteboard.php`, `/cvv/app/default/regappello.php`

## `/acc/app/default/crea_ticket.php` — Crea ticket di assistenza
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`, `/acc/app/default/me.php`, `/acc/app/default/crea_ticket.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`

## `/cvv/app/default/didattica_distanza_sottogruppo.php` — Gestione etichette sottogruppi
Parametri: `classe_id`
- chiamate negli script: `../../../tic/app/default/selezione_classi.php`, `didattica_distanza_sottogruppo.php`, `didattica_distanza_sottogruppo_io.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/didattica_distanza_sottogruppo.php`(classe_id), `/cvv/app/default/didattica_distanza.php`(classe_id,data_start), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regdidattica.php`(vista), `/cvv/app/default/gioprof_colloqui.php`, `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/regdidattica.php` — Didattica multimediale
Parametri: `vista`
- modulo `GET /cvv/app/default/didattica.php`: `cerca`
- modulo `GET /cvv/app/default/didattica.php`: `a`, `module_name`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/didattica_docenti.php`(classe_id,gruppo_id), `/cvv/app/default/regdidattica_compito.php`(vista,classe_id,gruppo_id), `/cvv/app/default/quiz.php`, `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regdidattica.php`(vista), `/cvv/app/default/gioprof_colloqui.php`, `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/orario_docente.php` — Orario Docente
- modulo `GET /cvv/app/default/orario_docente.php`: `periodo`, `ope`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/orario_docente.php`(ope), `/cvv/app/default/gioprof_selezione.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/dirigente_alunno.php` — Alunni
- modulo `GET /cvv/app/default/dirigente_alunno.php`: `cerca`
- chiamate negli script: `../../../sol/app/default/genitori_singolo.php`, `../../../s1c/app/default/tabellone_genitore.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/dirigente_alunno.php`(studente_id,stampa), `/cvv/app/default/alias.php`(studente_id,ckk)
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`, `/cvp/app/default/dettaglio_studente.php`, `/cvv/app/default/xml_export.php`, `/alw/app/default/scuola_alu_view.php`

## `/cvv/app/default/agenda.php` — Agenda di classe
Parametri: `classe_id`, `gruppo_id`
- chiamate negli script: `regclasse_io.php`, `regclasse_note_alunno.php`, `agenda.php`, `popup_compiti.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/gestione_aule.php`(classe_id,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id,mode,aula_id), `/cvv/app/default/richiami.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/regclasse.php`(granular,classe_id), `/cvv/app/default/regvoti.php`(classe_id), `/cvv/app/default/didattica.php`(classe_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,ope,codocenza,gruppo_id,materia), `/cvv/app/default/gioprof_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/gioprof_note.php` — Agenda
Parametri: `classe_id`, `gruppo_id`
- modulo `GET /cvv/app/default/gioprof_note.php`: `check_studente[N]`
- chiamate negli script: `regclasse_note_alunno.php`, `regclasse_io.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/gestione_aule.php`, `/cvv/app/default/agenda.php`(classe_id,gruppo_id,mode,aula_id), `/cvv/app/default/richiami.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,gruppo_id,ope,tipo,gruppo_id), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,ope,codocenza,gruppo_id,materia), `/cvv/app/default/gioprof_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/regwifi.php` — (senza titolo)
Parametri: `classe_id`, `gruppo_id`
- modulo `POST /cvv/app/default/regappello.php`: `action`, `classe_id`, `classe_desc`, `gruppo_id`, `account_id`, `data_start`, `granular`, `stato_N`, `ora_pos_N`, `stato_iniz_N`, `ora_pos_iniz_N`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regwifi.php`(classe_id,gruppo_id)
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/gioprof.php` — Registro
Parametri: `classe_id`, `materia`, `ope`, `codocenza`, `gruppo_id`
- chiamate negli script: `gioprof_relazioni.php`, `regclasse_io.php`, `regclasse_update_firma.php`, `gioprof_io.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/gioprof.php`(classe_id,materia,ope,codocenza,gruppo_id), `/cvv/app/default/coord_relazioni.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/gioprof_relazioni.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(gruppo_id,classe_id,materia_id,autore_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`, `/tools/app/default/stampacy.php`

## `/cvv/app/default/regvoti.php` — Situazione Valutazioni
Parametri: `classe_id`, `materia_id`, `gruppo_id`
- modulo `POST /cvv/app/default/regvoti.php`: `classe_id`, `colonne`, `materia_id`, `mode`, `quad`, `comp`, `gruppo_id`, `data_start`, `data_voto_tastiera`, `forza`, `usanuovecomp`, `usanuoveuda`, `materia`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/pdp/app/default/regvoti_uda.php`(classe_id,gruppo_id), `/cvv/app/default/regvoti_competenze.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regvoti_prove_strutturate.php`(classe_id,materia_id_cod,gruppo_id), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,materia_id,materia_id_cod,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/sol/app/default/scrutinio_singolo_recuperi.php`(quad,classe_id,materia_id,gruppo_id), `/cvv/app/default/regvoti_dettaglio.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/recuperi_docente.php`(quad,classe_id,materia_id,gruppo_id), `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,ope,codocenza,gruppo_id,materia), `/cvv/app/default/gioprof_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id), `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`, `/cmp/app/default/rubrica.php`

## `/cvv/app/default/disposizione.php` — Registro
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/disposizione.php`, `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regclasse.php`(classe_id,gruppo_id), `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/didattica_docenti.php` — Allegati multimediali condivisi
Parametri: `classe_id`, `gruppo_id`
- chiamate negli script: `didattica.php`, `didattica_docenti.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/didattica_docenti.php`(classe_id,gruppo_id), `/cvv/app/default/regdidattica_compito.php`(vista,classe_id,gruppo_id), `/cvv/app/default/quiz.php`(classe_id,gruppo_id), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regdidattica.php`(vista), `/cvv/app/default/gioprof_colloqui.php`, `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/regdidattica_compito.php` — Materiale compiti
Parametri: `vista`, `classe_id`, `gruppo_id`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/me.php`, `/acc/app/default/documentazione.php`, `/cvv/app/default/didattica_docenti.php`, `/cvv/app/default/regdidattica_compito.php`(classe_id), `/cvv/app/default/quiz.php`, `/cvv/app/default/regclasse.php`(granular,classe_id), `/cvv/app/default/regvoti.php`(classe_id), `/cvv/app/default/agenda.php`(classe_id), `/cvv/app/default/didattica.php`(classe_id), `/cvv/app/default/gioprof_selezione.php`, `/acc/app/default/documentazione1.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`

## `/cvv/app/default/quiz.php` — Quiz e Test
- modulo `GET /cvv/app/default/quiz.php`: `cerca`, `cat_id`, `anno_scol`, `ope`, `ordinamento`, `proprieta`, `stato`, `esito`, `archiviati`, `quiz_id`, `asg_id`
- chiamate negli script: `quiz.php`, `importa_quiz.php`, `ck_sess_connect.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/quiz.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id)
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`, `/cvv/app/default/xml_export.php`

## `/home/app/default/menu_webinfoschool.php` — Registri e didattica multimediale
- link: `/home/app/default/menu_classevivadocente.php`, `/acc/app/default/me.php`, `/acc/app/default/agenda.php`, `/acc/app/default/documentazione.php`, `/cvv/app/default/didattica_distanza.php`, `/ldt/app/default/libri_classi.php`, `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/selezione_classi.php`, `/cvv/app/default/selezione_gruppi.php`(corsoextra), `/cvv/app/default/didattica.php`, `/sif/app/default/bacheca_personale.php`, `/home/app/default/menu_scrutinionlinedocente.php`, `/cvv/app/default/gioprof_colloqui.php`, `/home/app/default/menu_verdi.php`, `/ber/app/default/compilazione_modulo.php`, `/home/app/default/menu_competenze.php`, `/home/app/default/menu_scuoladelfuturo.php`, `/cvv/`, `/cvv`, `/sol`, `/pdp/app/default/lista_studenti_pfi.php`, `/cmp/app/default/statistiche.php`, `/pdp/app/default/portfolio_studente.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/home/app/default/xasapi.php`, `/home/app/default/eligoauth.php`, `/ngs/app/default/richieste_utente_new.php`, `/f4s_web/learnin`, `/img/supremo.exe`, `/tic`, `/sdg/app/default/firma_anywhere.php`, `/ngs/`, `/ngs_pew/`, `/ngs_vew/`, `/ngs_com/`, `/ngs_mag/`, `/ngs_inv/`, `/ngs_rik/`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/sol/app/default/gioprof_scrutinionline.php` — Le mie classi
- modulo `GET /sol/app/default/gioprof_scrutinionline.php`: `cerca`
- modulo `GET /sol/app/default/gioprof_scrutinionline.php`: —
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/regvoti_proposti.php`(scrutinionline,classe_id,gruppo_id,materia_id)
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/home/app/default/menu_scrutinionline.php` — Lo Scrutinio on-line
- link: `/home/app/default/menu_scrutinionlinedocente.php`, `/acc/app/default/me.php`, `/sol/app/default/gioprof_scrutinionline.php`, `/home/app/default/menu_webinfoschool.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/home/app/default/xasapi.php`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/cvv/app/default/docenti_colloqui_generali.php` — Colloqui
Parametri: `autore_id`
- chiamate negli script: `docenti_colloqui_generali.php`, `gioprof_colloqui.php`, `colloquio_live.php`, `genitori_colloqui_generali.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/gioprof_colloqui.php`(autore_id), `/cvv/app/default/docenti_colloqui_generali.php`(autore_id), `/cvv/app/default/gioprof_sportello.php`, `/cvv/app/default/regdidattica.php`(vista), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/gioprof_sportello.php` — Sportello per gli alunni
- chiamate negli script: `.php`, `gioprof_sportello.php`, `gioprof_colloqui.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/gioprof_colloqui.php`(autore_id), `/cvv/app/default/docenti_colloqui_generali.php`(autore_id), `/cvv/app/default/gioprof_sportello.php`, `/cvv/app/default/regdidattica.php`(vista), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/ber/` — Bergantini - Home
- modulo `GET /ber/app/default/indici.php`: `cerca`, `view`, `page`, `anno`, `filtro[]`, `view2`, `cercaagg`
- link: `/ber/app/default/home.php`, `/acc/app/default/documentazione.php`, `/ber/app/default/indici.php`(cerca,view,cercaagg), `/ber/app/default/rivista.php`, `/ber/app/default/news.php`, `/ber/app/default/normativa.php`, `/home/app/default/menu_scuoladelfuturo.php`, `/acc/app/default/me.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/ber/riviste/2026_16/index.html`, `/home/app/default/informativa.php`, `/CUSTOM/policy/canali_tematici/privacy.html`, `/CUSTOM/policy/canali_tematici/cookies.html`, `/img/supremo.exe`

## `/cvv/app/default/regassenze.php` — Registro di classe
Parametri: `granular`, `classe_id`, `iniziali`, `data_start`, `gruppo_id`
- chiamate negli script: `regassenzeins.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/gestione_assenze.php`(classe_id), `/cvv/app/default/regassenze.php`(granular,classe_id,iniziali,data_start,gruppo_id,ope), `/cvv/app/default/regclasse.php`(granular,classe_id,cerca,iniziali), `/cvv/app/default/regvoti.php`(classe_id), `/cvv/app/default/agenda.php`(ope,classe_id), `/cvv/app/default/didattica.php`(classe_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,ope,codocenza,gruppo_id,materia), `/cvv/app/default/gioprof_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id), `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/gioprof_relazioni.php` — Il Giornale del Professore
Parametri: `classe_id`, `gruppo_id`, `materia_id`
- modulo `GET /cvv/app/default/gioprof_relazioni.php`: `text_nota`, `ope`
- modulo `POST /cvv/app/default/gioprof_relazioni.php`: `user_file`, `ope`, `materia_id`, `classe_id`, `gruppo_id`, `posizione_id`
- modulo `POST /cvv/app/default/gioprof_relazioni.php`: `user_file`, `ope`, `materia_id`, `classe_id`, `gruppo_id`, `posizione_id`
- modulo `POST /cvv/app/default/gioprof_relazioni.php`: `user_file`, `ope`, `materia_id`, `classe_id`, `gruppo_id`, `posizione_id`
- modulo `POST /cvv/app/default/gioprof_relazioni.php`: `user_file`, `ope`, `materia_id`, `classe_id`, `gruppo_id`, `posizione_id`
- chiamate negli script: `gioprof_relazioni.php`, `/cmp/app/default/rubrica_io.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_relazioni.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,materia,ope,gruppo_id), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,gruppo_id,autore_id,materia_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/programma_struttura.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/gioprof_relazioni_prec.php`, `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/regvoti_proposti.php` — Voti Proposti
Parametri: `classe_id`, `gruppo_id`, `materia_id`
- chiamate negli script: `regvoti_proposti_io.php`, `regvoti_proposti.php`, `regvoti_medie.php`, `/sol/app/default/competenze_proposte.php`, `stampa_filtro_dialog.php`, `/sol/app/default/giudizio.php`, `/sol/app/default/tabellone_scrutinio_serale.php`, `/sol/app/default/scrutina_singolo_io.php`, `regvoti_prove_strutturate_io.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/pdp/app/default/regvoti_uda.php`(classe_id,gruppo_id), `/cvv/app/default/regvoti_prove_strutturate.php`(classe_id,cerca,iniziali,materia_id_cod,gruppo_id), `/sol/app/default/competenze_proposte.php`(classe_id,materia_id,gruppo_id,infra), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,materia_id,cerca,iniziali,materia_id_cod,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regvoti_proposti.php`(gruppo_id,classe_id,materia_id,competenze,infra), `/sol/app/default/scrutinio_singolo_recuperi.php`(quad,classe_id,materia_id,gruppo_id,proposti,infra), `/cvv/app/default/dirigente_alunno.php`(studente_id), `/sol/app/default/regvoti_tassonomie.php`(gruppo_id,classe_id,materia_id,quad,contesto)
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`, `/sol/app/default/firma_scrutinio.php`, `/sol/app/default/etichette_uda.php`, `/tools/app/default/stampacy.php`

## `/cvv/app/default/coord_relazioni.php` — Il Giornale del Professore
Parametri: `classe_id`, `gruppo_id`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_relazioni.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,materia,ope,gruppo_id), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/richiami.php` — Richiami
Parametri: `classe_id`, `gruppo_id`
- modulo `GET /cvv/app/default/richiami.php`: `classe_id`, `classe_desc`, `gruppo_id`, `account_id`
- modulo `GET /cvv/app/default/richiami.php`: `richiami`, `check_studente[]`
- chiamate negli script: `richiami.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/richiami.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/regclasse.php`(classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/regdidattica.php`(vista,classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`, `/cvv/app/default/richiami_print.php`, `/cvv/app/default/xml_export.php`

## `/cvv/app/default/alias.php` — (senza titolo)
Parametri: `studente_id`, `ckk`
- chiamate negli script: `/home/app/default/login.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/login.php`

## `/cvv/app/default/gestione_aule.php` — Gestione Aule
Parametri: `classe_id`, `gruppo_id`
- modulo `GET /cvv/app/default/gestione_aule.php`: `tutte_classi[]`
- chiamate negli script: `gestione_aule.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/agenda.php`(classe_id,gruppo_id,mode), `/cvv/app/default/gestione_aule.php`(ope)
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/pdp/app/default/regvoti_uda.php` — Situazione Uda
Parametri: `classe_id`, `gruppo_id`
- chiamate negli script: `questionario_compilazione.php`, `regvoti_uda.php`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,materia_id_cod,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/pdp/app/default/regvoti_uda.php`(classe_id,gruppo_id,studente_id,mostra_tutto)
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/regvoti_competenze.php` — Situazione Competenze
Parametri: `classe_id`, `gruppo_id`, `materia_id`
- chiamate negli script: `regvoti_proposti.php`, `regvoti_competenze.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/regvoti_competenze.php`(ope,classe_id,gruppo_id,materia_id), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,cerca,iniziali,materia_id_cod,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,ope,codocenza,gruppo_id,materia), `/cvv/app/default/gioprof_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id), `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/regvoti_prove_strutturate.php` — (senza titolo)
Parametri: `classe_id`, `materia_id_cod`, `gruppo_id`
- modulo `POST /cvv/app/default/regvoti_compito.php`: `classe_id`, `materia_id`, `materia_id_cod`, `data_start`, `prova_id`, `granular`
- chiamate negli script: `regvoti_prove_strutturate_io.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/regvoti_prove_strutturate.php`(classe_id,materia_id_cod,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,cerca,iniziali,materia_id_cod,materia_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,cerca,iniziali,materia_id_cod,materia_id), `/cvv/app/default/regclasse.php`(granular,classe_id,cerca,iniziali)
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/sol/app/default/scrutinio_singolo_recuperi.php` — Scrutini online
Parametri: `quad`, `classe_id`, `materia_id`, `gruppo_id`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/sol/app/default/tabellone_recupero.php`, `/sol/app/default/scrutinio_singolo_recuperi.php`(quad,classe_id,materia_id,gruppo_id,proposti,infra), `/sol/app/default/scrutinio_singolo_recuperi_docente.php`(quad,classe_id,materia_id,gruppo_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/regvoti.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/regvoti_dettaglio.php` — Situazione Valutazioni
Parametri: `classe_id`, `materia_id`, `gruppo_id`
- chiamate negli script: `regvoti_dettaglio.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/regclasse.php`(granular,classe_id,gruppo_id), `/cvv/app/default/regvoti.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`(classe_id,gruppo_id), `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/regvoti_dettaglio.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,ope,codocenza,gruppo_id,materia), `/cvv/app/default/gioprof_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id), `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/recuperi_docente.php` — (senza titolo)
Parametri: `quad`, `classe_id`, `materia_id`, `gruppo_id`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/regvoti_proposti.php`, `/cvv/app/default/regvoti.php`, `/cvv/app/default/recuperi_docente.php`(quad,classe_id,materia_id,gruppo_id,offset), `/cvv/app/default/regclasse.php`(classe_id,gruppo_id), `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,ope,codocenza,gruppo_id,materia), `/cvv/app/default/gioprof_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`, `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id), `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/acc/app/default/documentazione1.php` — Crea ticket di assistenza
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`, `/acc/app/default/me.php`, `/acc/app/default/crea_ticket.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`

## `/ber/app/default/home.php` — Bergantini - Home
- modulo `GET /ber/app/default/indici.php`: `cerca`, `view`, `page`, `anno`, `filtro[]`, `view2`, `cercaagg`
- link: `/ber/app/default/home.php`, `/acc/app/default/documentazione.php`, `/ber/app/default/indici.php`(cerca,view,cercaagg), `/ber/app/default/rivista.php`, `/ber/app/default/news.php`, `/ber/app/default/normativa.php`, `/home/app/default/menu_scuoladelfuturo.php`, `/acc/app/default/me.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/ber/riviste/2026_16/index.html`, `/home/app/default/informativa.php`, `/CUSTOM/policy/canali_tematici/privacy.html`, `/CUSTOM/policy/canali_tematici/cookies.html`, `/img/supremo.exe`

## `/ber/app/default/indici.php` — Bergantini - Indici
Parametri: `cerca`, `view`, `cercaagg`
- modulo `GET /ber/app/default/rivista.php`: `cerca`, `view`, `page`, `anno`, `filtro[]`, `view2`, `cercaagg`
- link: `/ber/app/default/home.php`, `/acc/app/default/documentazione.php`, `/ber/app/default/indici.php`(cerca,view,cercaagg), `/acc/app/default/me.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/ber/riviste/2026_16/index.html`, `/CUSTOM/policy/canali_tematici/privacy.html`, `/home/app/default/informativa.php`, `/CUSTOM/policy/canali_tematici/cookies.html`, `/img/supremo.exe`

## `/ber/app/default/rivista.php` — Bergantini - Rivista
- modulo `GET /ber/app/default/rivista.php`: `cerca`, `view`, `page`, `anno`, `filtro[]`, `view2`, `cercaagg`
- link: `/ber/app/default/home.php`, `/acc/app/default/documentazione.php`, `/ber/app/default/rivista.php`, `/acc/app/default/me.php`, `/ber/app/default/indici.php`(view,cerca)
- link non visitati (scrittura, esterni o fuori dal registro): `/ber/riviste/2026_16/index.html`, `/ber/riviste/2026_15/index.html`, `/ber/riviste/2026_14/index.html`, `/ber/riviste/2026_13/index.html`, `/ber/riviste/2026_12/index.html`, `/ber/riviste/2026_11/index.html`, `/ber/riviste/2026_10/index.html`, `/ber/riviste/2026_09/index.html`, `/ber/riviste/2026_08/index.html`, `/ber/riviste/2026_07/index.html`, `/ber/riviste/2026_06/index.html`, `/ber/riviste/2026_S1/index.html`, `/ber/riviste/2026_05/index.html`, `/ber/riviste/2026_04/index.html`, `/ber/riviste/2026_03/index.html`, `/ber/riviste/2026_02/index.html`, `/ber/riviste/2026_01/index.html`, `/home/app/default/informativa.php`, `/CUSTOM/policy/canali_tematici/privacy.html`, `/CUSTOM/policy/canali_tematici/cookies.html`, `/img/supremo.exe`

## `/ber/app/default/news.php` — Bergantini - News
- modulo `GET /ber/app/default/news.php`: `cerca`, `view`, `page`, `anno`, `filtro[]`, `view2`, `cercaagg`
- link: `/ber/app/default/home.php`, `/acc/app/default/documentazione.php`, `/ber/app/default/news.php`, `/acc/app/default/me.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/informativa.php`, `/CUSTOM/policy/canali_tematici/privacy.html`, `/CUSTOM/policy/canali_tematici/cookies.html`, `/img/supremo.exe`

## `/ber/app/default/normativa.php` — Bergantini - Normativa
- modulo `GET /ber/app/default/normativa.php`: `cerca`, `view`, `page`, `anno`, `filtro[]`, `view2`, `cercaagg`
- link: `/ber/app/default/home.php`, `/acc/app/default/documentazione.php`, `/ber/app/default/normativa.php`, `/acc/app/default/me.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/informativa.php`, `/CUSTOM/policy/canali_tematici/privacy.html`, `/CUSTOM/policy/canali_tematici/cookies.html`, `/img/supremo.exe`

## `/cvv/app/default/gestione_assenze.php` — Ricerca Scuola - Gateway delle Identità
Parametri: `classe_id`
- modulo `POST /iwis-eidgateway-ricercaaggregati-web/school/search/next`: `request_id`, `client_id`, `redirect_uri`, `state`, `login_uri`, `school`, `saveForFutureVisits`

## `/cvv/app/default/programma_struttura.php` — Il Giornale del Professore
Parametri: `classe_id`, `materia_id`, `gruppo_id`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/gioprof_relazioni.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/regclasse.php`(classe_id,gruppo_id), `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,ope,codocenza,gruppo_id,materia), `/cvv/app/default/regvoti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regvoti_proposti.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`, `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id), `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/cvv/app/default/gioprof_relazioni_prec.php` — Il Giornale del Professore
- modulo `POST /cvv/app/default/gioprof_relazioni_prec.php`: `user_file`, `ope`, `materia_id`, `classe_id`, `gruppo_id`, `posizione_id`
- modulo `POST /cvv/app/default/gioprof_relazioni_prec.php`: `user_file`, `ope`, `materia_id`, `classe_id`, `gruppo_id`, `posizione_id`
- modulo `POST /cvv/app/default/gioprof_relazioni_prec.php`: `user_file`, `ope`, `materia_id`, `classe_id`, `gruppo_id`, `posizione_id`
- chiamate negli script: `gioprof_relazioni_prec.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/gioprof_relazioni_prec.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/regclasse.php`(classe_id,gruppo_id), `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`, `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/sol/app/default/competenze_proposte.php` — Competenze Proposte
Parametri: `classe_id`, `materia_id`, `gruppo_id`, `infra`
- chiamate negli script: `competenze_proposte.php`, `/cvv/app/default/ck_sess_connect.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/sol/app/default/competenze_proposte.php`(classe_id,materia_id,gruppo_id,infra), `/cvv/app/default/regvoti_proposti.php`(classe_id,materia_id,gruppo_id), `/cvv/app/default/regvoti_competenze.php`(classe_id,gruppo_id,materia_id), `/sol/app/default/gioprof_scrutinionline.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/sol/app/default/regvoti_tassonomie.php` — Scrutini online
Parametri: `gruppo_id`, `classe_id`, `materia_id`, `quad`, `contesto`
- chiamate negli script: `../../../sol/app/default/giudizio.php`
- link: `/home/app/default/menu_scrutinionline.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/sol/app/default/regvoti_tassonomie.php`(quad,mode,classe_id,materia_id,gruppo_id,scrutinionline), `/cvv/app/default/regvoti_proposti.php`(classe_id,infra,materia_id,gruppo_id,scrutinionline), `/sol/app/default/gioprof_scrutinionline.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`

## `/sol/app/default/tabellone_recupero.php` — Registri e didattica multimediale
- link: `/home/app/default/menu_classevivadocente.php`, `/acc/app/default/me.php`, `/acc/app/default/agenda.php`, `/acc/app/default/documentazione.php`, `/cvv/app/default/didattica_distanza.php`, `/ldt/app/default/libri_classi.php`, `/cvv/app/default/gioprof_selezione.php`, `/cvv/app/default/selezione_classi.php`, `/cvv/app/default/selezione_gruppi.php`(corsoextra), `/cvv/app/default/didattica.php`, `/sif/app/default/bacheca_personale.php`, `/home/app/default/menu_scrutinionlinedocente.php`, `/cvv/app/default/gioprof_colloqui.php`, `/home/app/default/menu_verdi.php`, `/ber/app/default/compilazione_modulo.php`, `/home/app/default/menu_competenze.php`, `/home/app/default/menu_scuoladelfuturo.php`, `/cvv/`, `/cvv`, `/sol`, `/pdp/app/default/lista_studenti_pfi.php`, `/cmp/app/default/statistiche.php`, `/pdp/app/default/portfolio_studente.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/home/app/default/logout.php`, `/home/app/default/xasapi.php`, `/home/app/default/eligoauth.php`, `/ngs/app/default/richieste_utente_new.php`, `/f4s_web/learnin`, `/img/supremo.exe`, `/tic`, `/sdg/app/default/firma_anywhere.php`, `/ngs/`, `/ngs_pew/`, `/ngs_vew/`, `/ngs_com/`, `/ngs_mag/`, `/ngs_inv/`, `/ngs_rik/`, `/CUSTOM/policy/web/privacy.html`, `/CUSTOM/policy/web/cookies.html`, `/CUSTOM/policy/web/condizioni_generali.html`

## `/sol/app/default/scrutinio_singolo_recuperi_docente.php` — (senza titolo)
Parametri: `quad`, `classe_id`, `materia_id`, `gruppo_id`
- link: `/home/app/default/menu_classeviva.php`, `/acc/app/default/documentazione.php`(prodotto,ref), `/cvv/app/default/regvoti_proposti.php`, `/cvv/app/default/regvoti.php`, `/cvv/app/default/recuperi_docente.php`(quad,classe_id,materia_id,gruppo_id,offset), `/cvv/app/default/regclasse.php`(classe_id,gruppo_id), `/cvv/app/default/regassenze.php`(granular,classe_id,gruppo_id), `/cvv/app/default/gioprof_note.php`(classe_id,ope,tipo,gruppo_id), `/cvv/app/default/gioprof.php`(classe_id,ope,codocenza,gruppo_id,materia), `/cvv/app/default/gioprof_relazioni.php`(classe_id,gruppo_id,materia_id), `/cvv/app/default/agenda.php`(classe_id,gruppo_id), `/cvv/app/default/didattica.php`, `/cvv/app/default/gioprof_colloqui.php`, `/cvv/app/default/coord_relazioni.php`(classe_id,gruppo_id), `/cvv/app/default/richiami.php`(classe_id,gruppo_id), `/sif/app/default/bacheca_personale.php`
- link non visitati (scrittura, esterni o fuori dal registro): `/sso/app/default/me.php`, `/home/app/default/logout.php`
