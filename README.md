# PromoSpesa 🛒

Applicazione mobile in Flutter per monitorare le offerte e le promozioni nei supermercati della tua zona, con rimozione automatica dei prodotti alla data di scadenza della promozione.

## Caratteristiche
- **Punti Vendita Personalizzati**: Inserimento supermercati con marchio (es. Conad, Esselunga, Coop, Lidl) e indirizzo/zona.
- **Offerte Dettagliate**: Nome prodotto, marca, prezzo promo, prezzo intero originale e date di inizio/fine offerta.
- **Scadenza Automatica**: Le offerte la cui data di fine è antecedente a oggi non vengono mostrate nel catalogo attivo e possono essere rimosse periodicamente dal database.
- **Filtri e Ricerca Rapida**: Filtra istantaneamente per catena/negozio o cerca per prodotto/marca.
- **Compilazione Cloud**: Workflow GitHub Actions pronto che genera il file `.apk` senza dover installare Android Studio sul PC.

---

## 1. Configurazione Firebase
L'app utilizza **Cloud Firestore** per archiviare le offerte online in tempo reale:

1. Vai su [Firebase Console](https://console.firebase.google.com/) e crea un nuovo progetto (es. `promospesa`).
2. Aggiungi un'app **Android**:
   - **Nome pacchetto**: `com.promospesa.app`
3. Scarica il file `google-services.json` e posizionalo in:
   `android/app/google-services.json`
4. Nella sezione **Firestore Database**, crea il database (in modalità test o con regole di lettura/scrittura per utenti autenticati/pubblici).

---

## 2. Come generare l'APK con GitHub Actions

1. Crea un repository su [GitHub](https://github.com/new) (es. `promo-spesa`).
2. Carica tutti i file di questo progetto sul repository.
3. Se non vuoi caricare il file `google-services.json` pubblicamente nel repository Git:
   - Vai nelle **Settings** del repository GitHub -> **Secrets and variables** -> **Actions**.
   - Aggiungi un Secret chiamato `GOOGLE_SERVICES_JSON_BASE64` incollando il contenuto del tuo `google-services.json` codificato in Base64 (oppure carica direttamente il file `android/app/google-services.json` se il repository è privato).
4. Vai nella scheda **Actions** su GitHub, seleziona il workflow **Build Android APK** e clicca su **Run workflow** (oppure fai semplicemente un commit/push).
5. Al termine (circa 3-4 minuti), nella sezione **Artifacts** troverai `app-release-apk` pronto per essere scaricato sul tuo telefono Android e installato!
