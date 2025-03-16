# 📂 CombineFiles PowerShell (modulare)- Guida per Sviluppatori


## 📁 Struttura del Repository

### 🔹 Versione standalone (script singolo)
- **`Combine-Files.ps1`** → Versione standalone dello script principale.
- **`README.md`** → Documentazione di utilizzo.

### 🔹 Versione modulare (PowerShell Module)
All'interno della cartella `ModularVersion/` si trova la versione strutturata come modulo PowerShell, con file separati per migliorare la manutenibilità e l'estensibilità.

#### 📂 `ModularVersion/`
- **`CombineFiles.psd1`** → File di definizione del modulo PowerShell.
- **`CombineFiles.psm1`** → Modulo principale, che importa i moduli secondari.
- **`Main.ps1`** → Script entry point, per testare le funzionalità del modulo.
- **`Presets.psm1`** → Definisce preset preconfigurati per la combinazione di file.
- **`PowerShellModuleProject1.pssproj`** → File di progetto PowerShell.
- **`README.md`** → Documentazione specifica per l'uso della versione modulare.

#### 📂 Sottocartelle del Modulo
- **`FileSelection/`**
  - `FileSelection.psm1` → Funzioni per la selezione dei file basate su estensioni, regex e percorsi esclusi.

- **`InteractiveSelection/`**
  - `InteractiveSelection.psm1` → Funzioni per la selezione interattiva dei file (es. apertura con un editor di testo per modificare la lista dei file da combinare).

- **`Logging/`**
  - `Logging.psm1` → Funzionalità di logging per il debug e il tracciamento delle operazioni.

- **`Utilities/`**
  - `Utilities.psm1` → Funzioni di utilità generiche (gestione percorsi, conversione dimensioni, ecc.).

---

## 🚀 Come Contribuire

1. **Clona il repository**
   ```sh
   git clone https://github.com/tuo-user/CombineFiles-PowerShell.git
   cd CombineFiles-PowerShell/ModularVersion
   ```
2. **Importa il modulo**
   ```powershell
   Import-Module .\CombineFiles.psm1 -Force
   ```
3. **Esegui il test dello script**
   ```powershell
   .\Main.ps1
   ```
4. **Modifica e contribuisci**
   - Se aggiungi nuove funzionalità, crea un nuovo `.psm1` separato.
   - Aggiorna `CombineFiles.psm1` per importare il nuovo modulo.
   - Aggiorna la documentazione (`README.md`).

---

## 🔥 Best Practices
- **Separa le responsabilità** → Mantieni le funzioni specifiche nei loro rispettivi moduli.
- **Commenta il codice** → Usa `#` per spiegare le funzioni chiave.
- **Testa le modifiche** → Verifica il funzionamento con `Main.ps1` prima di committare.

---

## 📌 Note Finali
Questa versione modulare rende il progetto più scalabile e manutenibile. Se hai suggerimenti o vuoi contribuire, apri una pull request!

🚀 **Happy coding!** 🚀

