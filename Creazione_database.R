library(DBI)
library(RSQLite)

# Stabilimento della connessione al database SQL
connessione <- dbConnect(SQLite(), "pazienti.sqlite")
# Creazione del dataset e delle tabelle
dbExecute(connessione, "CREATE TABLE pazienti (
          ID int PRIMARY KEY,
          Numero_accessi int,
          Costo_per_accesso float);")
dbExecute(connessione, "CREATE TABLE caratteristiche_pazienti (
          ID int PRIMARY KEY,
          Età int,
          Settore_lavorativo varchar(255),
          Fumatore bool,
          Sesso varchar(255),
          Patologie_croniche int,
          ISEE float);")
# Generazione delle covariate
set.seed(44441)
età <- sample(20:90, size=4000, replace=T)
settore <- sample(c("Primario", "Secondario", "Terziario"), size=4000, replace=T)
fumatori <- sample(c(TRUE, FALSE), size=4000, replace=T)
sesso <- sample(c("M", "F"), size=4000, replace=T)
patologie <- 1+rpois(4000, 0.373)
isee <- rnorm(4000, 50000, 25000)
accessi <- rpois(4000, 1.286)
epsilon.costi <- rnorm(4000, 0, 105)
intercetta <- 669
# Generazione della variabile risposta
costi <- (intercetta+100.814*accessi+3.19*età+431.88*(settore == "Secondario")-200.01*(settore == "Terziario")
          +194.29*fumatori-22.11*(sesso == "F")+680.70*patologie-0.002709*isee+epsilon.costi)
# Inserimento del dataset
pazienti <- data.frame(ID = 1:4000,
                       Numero_accessi = accessi,
                       Costo_per_accesso = costi,
                       Età = età,
                       Settore_lavorativo = settore,
                       Fumatore = fumatori,
                       Sesso = sesso,
                       Patologie_croniche = patologie,
                       ISEE = isee)
for (id in pazienti$ID) {
  r <- pazienti[pazienti$ID == id,]
  prima.query <- paste0("INSERT INTO pazienti VALUES (", id, ", ",
                        r$Numero_accessi, ", ", r$Costo_per_accesso, ");")
  seconda.query <- paste0("INSERT INTO caratteristiche_pazienti VALUES (",
                          id, ", ", r$Età, ", '", r$Settore_lavorativo, "', '",
                          r$Fumatore, "', '", r$Sesso, "', ",
                          r$Patologie_croniche, ", ", r$ISEE, ");")
  dbExecute(connessione, prima.query)
  dbExecute(connessione, seconda.query)
}
dbDisconnect(connessione)
# Aggiuntivo salvataggio come file Excel
write.csv(pazienti, file="pazienti.csv")
