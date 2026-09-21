# didUP Famiglia — contratto statico APK

Artefatto analizzato: `didUP Famiglia 1.30.2`, package `it.argosoft.didup.famiglia.new`, versionCode `440`, Flutter release, split `armeabi-v7a`.

## Endpoint confermati da `libapp.so`

- OAuth discovery: `https://auth.portaleargo.it/.well-known/openid-configuration`
- OAuth authorize: `https://auth.portaleargo.it/oauth2/auth`
- OAuth token: `https://auth.portaleargo.it/oauth2/token`
- Redirect: `it.argosoft.didup.famiglia.new://login-callback`
- API: `https://didattica.portaleargo.it/famiglia/api`
- Login applicativo: `POST /login`
- Dashboard aggregata: `POST /dashboard/dashboard2`
- Refresh token: `POST /auth/refresh-token`
- Aggiornamento dashboard: `POST /dashboard/aggiornadata`

L’APK contiene inoltre queste famiglie di route, ma il payload completo va verificato prima di implementare operazioni mutanti:

`/bacheca`, `/bachecaalunno`, `/famiglia/giustifica2`, `/famiglia/nuovodocumento`, `/famiglia/modificadocumento`, `/famiglia/cancella-documento2`, `/famiglia/presavisioneadesione`, `/famiglia/presavisionebachecaalunno`, `/famiglia/presavisionenote`, `/famiglia/votiscrutinio`, `/ricevimento/*`, `/preautorizzazioni/*`, `/pagamenti/*`, `/notifiche`, `/profilo`.

## Header confermati

- `Authorization: Bearer <access_token>`
- `x-auth-token: <token profilo>`
- `x-cod-min: <codice ministeriale/scuola>`
- `argo-client-version: 1.30.2`
- `Content-Type: application/json; charset=utf-8`

## Body confermati

`POST /login`:

```json
{
  "lista-opzioni-notifiche": "{}",
  "lista-x-auth-token": "[]",
  "clientID": "<random 163-character value>"
}
```

`POST /dashboard/dashboard2`:

```json
{
  "dataultimoaggiornamento": "2000-01-01 00:00:00.000",
  "opzioni": "<JSON string delle opzioni profilo>"
}
```

## Dashboard mappabile

`data.dati[0]` espone almeno: `voti`, `appello`, `registro`, `bacheca`, `bachecaAlunno`, `promemoria`, `listaDocentiClasse`, `listaPeriodi`, `listaMaterie`, `noteDisciplinari`, `mediaPeriodi`, `fileCondivisi`, `prenotazioniAlunni`.

Campi voto confermati: `pk`, `codTipo`, `codCodice`, `prgVoto`, `codVotoPratico`, `pkMateria`, `desMateria`, `pkDocente`, `docente`, `datGiorno`, `valore`, `numMedia`, `descrizioneVoto`, `pkPeriodo`, `desCommento`, `faMenoMedia`, `datEvento`.

## Implementazione nel progetto

`DidUpRemoteDatasource` implementa PKCE URL generation, code exchange, refresh, login applicativo e dashboard parsing senza loggare token o credenziali.

Non sono stati contattati endpoint Argo e non sono state usate credenziali reali. Le operazioni di scrittura restano intenzionalmente non abilitate finché non esiste una cattura redatta/autorizzata o un fixture ufficiale.
