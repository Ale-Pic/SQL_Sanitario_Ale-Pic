library(DBI)
library(RSQLite)

# Stabilimento della connessione al database SQL
connessione <- dbConnect(SQLite(), "pazienti.sqlite")
# Importazione del dataset da SQL
pazienti.regressione <- dbGetQuery(connessione, "SELECT Numero_accessi, Costo_per_accesso, Età, 
                                                 Settore_lavorativo, Fumatore, Sesso, Patologie_croniche, ISEE
                                                 FROM pazienti JOIN caratteristiche_pazienti ON pazienti.ID == caratteristiche_pazienti.ID;")
regressione <- lm(Costo_per_accesso ~ Numero_accessi + Età + Settore_lavorativo 
                  + Fumatore + Sesso + Patologie_croniche + ISEE, data=pazienti.regressione)
summary(regressione)
