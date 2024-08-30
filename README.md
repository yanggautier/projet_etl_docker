# Projet ETL SuperStore avec Docker

## Description du projet

Ce projet implémente un pipeline ETL (Extract, Transform, Load) complet pour traiter les données de ventes d'un supermarché fictif appelé SuperStore. Il utilise Docker pour créer un environnement de développement reproductible, intégrant MySQL pour le stockage des données, Jupyter Notebook pour l'analyse, et un script de prétraitement Python pour le nettoyage des données.

## Structure du projet

```
├── README.md
├── analyse
│   ├── Dockerfile
│   ├── analyse.ipynb
│   └── requirements.txt
├── data
│   ├── SuperStoreRawData.csv
│   └── preprocessed_output.csv
├── db
│   └── init.sql
├── docker-compose.yml
└── preprocess
    ├── Dockerfile
    ├── data
    ├── etl.ipynb
    └── preprocess.py
```

## Prérequis

- Docker
- Docker Compose

## Installation et démarrage

1. Clonez ce dépôt :
   ```
   git clone git@github.com:yanggautier/projet_etl_docker.git
   cd projet-etl-docker
   ```

2. Lancez les conteneurs Docker :
   ```
   docker-compose up -d
   ```

3. Accédez à Jupyter Notebook pour l'analyse :
   Ouvrez un navigateur et allez à `http://localhost:8888`

## Utilisation

1. **Prétraitement des données** : 
   - Le script `preprocess.py` nettoie les données brutes de `SuperStoreRawData.csv`.
   - Le résultat est sauvegardé dans `preprocessed_output.csv`.

2. **Chargement des données** :
   - Le script `init.sql` crée la structure de la base de données et charge les données prétraitées.

3. **Analyse des données** :
   - Utilisez le notebook Jupyter `analyse.ipynb` pour effectuer des analyses sur les données chargées.

## Composants du projet

- **MySQL** : Stockage des données nettoyées.
- **Jupyter Notebook** : Environnement d'analyse interactif.
- **Adminer** : Interface web pour gérer la base de données MySQL.
- **Python** : Utilisé pour le prétraitement des données et l'analyse.

## Contribution

Les contributions à ce projet sont les bienvenues. Veuillez suivre ces étapes :

1. Forkez le projet
2. Créez votre branche de fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request
