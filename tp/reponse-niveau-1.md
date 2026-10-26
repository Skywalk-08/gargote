# Réponses niveau 1

## A. Base de données
### 1.1 Script de migration
1. __Date_jour__ en clé primaire pour garantir la règle « un seul plat du jour par jour », sans aucune ligne de PHP
2. En ajoutant une colonne `est_plat_du_jour BOOLEAN` dans `plat`, on perd la date du plat du jour et les historiaues des dates précédentes

### 1.2 Données de test
3. `Erreur` : psql:niveau1_donnees.sql:63: ERROR:  new row for relation "plat" violates check constraint "plat_prix_positif"
              DETAIL:  Failing row contains (16, Test prix zero, 0, 1, Plat de test, t).
              psql:niveau1_donnees.sql:72: ERROR:  duplicate key value violates unique constraint "plat_nom_unique"
              DETAIL:  Key (nom)=(Koba) already exists.

## B. API et code métier
### 1.5 Le plat du jour
4. R2 renvoye 409 car c'est une erreur d'état de plat mais les données ne sont pas invalides sinon on retournerait 422
5. Si Bao marque comme épuisé un plat qui est déjà le plat du jour, il faut retirer ce plat de la sélection du jour, car il n'est plus disponible pour les clients parce qu'un plat du jour doit pouvoir être commandé. Si le plat est épuisé, continuer à l'afficher comme plat du jour risque d'induire les clients en erreur.

### 1.7 Jeu de tests
| Requête | Réponses |
|---|---|
| `curl -i -X POST http://localhost:8080/api/plats -H "Content-Type: application/json" -d '{"nom":"Café","prix":1000,"id_categorie":3}'` | 422,  {"message": "Données invalides.","errors": {"nom": "Un plat portant ce nom existe déjà."}} |
| `curl -i -X PUT http://localhost:8080/api/plats/4 -H "Content-Type: application/json" -d '{"nom":"Romazava","prix":7500}'` | 200 |
| `curl -i -X POST http://localhost:8080/api/plats -H "Content-Type: application/json" -d '{"nom":"Thé","prix":0,"id_categorie":3}'` | 422, {"message": "Données invalides.", "errors": {"prix": "Le prix doit être supérieur à zéro." }} |
| `curl -i -X POST http://localhost:8080/api/plats -H "Content-Type: application/json" -d '{"nom":"Thé","prix":500,"id_categorie":99}'` | 422, {"message": "Données invalides.", "errors": {"id_categorie": "Le champ id_categorie doit contenir une valeur existant déjà dans la base de données.}} |
| `curl -i -X PUT http://localhost:8080/api/plats/7 -H "Content-Type: application/json" -d '{"disponible":"oui"}'` | 422, {"message": "Données invalides.", "errors": { "disponible": "La disponibilité doit être un booléen (true ou false)." }} |
| `curl -i -X PUT http://localhost:8080/api/plats/7 -H "Content-Type: application/json" -d '{"disponible":false}'` | 200, { "id": 7, "nom": "Mi sao", "prix": 6500, "id_categorie": 2, "description": null, "disponible": false} |
| `curl -i -X PUT http://localhost:8080/api/plat-du-jour -H "Content-Type: application/json" -d '{"id_plat":7}'` | 409, { "status": 409, "error": 409, "messages": {     "error": "Le plat est épuisé : il ne peut pas être plat du jour." }} |
| `curl -i -G http://localhost:8080/api/plats -H "Accept: application/json" --data-urlencode "categorie=2" --data-urlencode "disponible=1"` | 200, [{ "id": 6, "nom": "Soupe chinoise", "prix": 6000, "id_categorie": 2, "description": null, "disponible": true, "categorie": "Soupe" }] |

6. Avant d’ajouter la règle __is_not_unique__, la quatrième requête renvoyait une erreur `500 Internal Server Error` parce que la catégorie 99 n’existait pas dans la table categorie, c’était PostgreSQL qui détectait l'erreur au moment où CodeIgniter essayait d’insérer le plat dans la base de données. La règle __is_not_unique[categorie.id]__ permet à CodeIgniter de vérifier l'existence de la catégorie avant l'insertion et de renvoyer une erreur 422 compréhensible par le client.

## D. Interface Vue
7. `curl -i -X POST http://localhost:8080/api/commandes -H "Content-Type: application/json" -d '{ "numero_table": 1, "lignes": [{"id_plat": 7, "quantite": 1}]}'`
