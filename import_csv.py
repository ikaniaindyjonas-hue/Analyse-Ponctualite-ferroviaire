import pandas as pd
import sqlite3 as sql


# connexion à la base de donnnée 
conn = sql.connect('database/trainrides.db')

# importation des données depuis le fichier CSV
df = pd.read_csv('data/TrainRides_clean.csv')

# création des tables dans la base de données
df.to_sql('TrainRides_clean', conn, if_exists='replace', index=False)

print("Données importées avec succès dans la base de données SQLite.")

conn.close()
