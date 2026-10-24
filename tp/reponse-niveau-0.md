# Réponses niveau 0

## 0.2
1 . Schéma relationnel
Categorie(<u>id</u>, libelle)
Plat(<u>id</u>, nom, prix, #id_categorie)
Commande(<u>id</u>, date_commande, numero_table)
Commande_ligne(<u>id</u>, #id_commande, #id_plat, quantite, prix_unitaire)

2 . Parce que prix_unitaire garde le prix du plat au moment où la commande a été passée, le prix dans plat.prix peut changer plus tard.
*Exemple :* aujourd'hui plat => id = 2,nom = Romazava,prix = 3000
            un client commande 2 romazava commande_ligne => id_plat = 2,quantite = 2,prix_unitaire = 3000
            demain le prix du romazava change plat.prix = 3500
            l'ancienne commande doit quand même rester à 3000 Ar par Romazava, et non passer automatiquement à 3500 Ar

3 . Les lignes associées à cette commande sont automatiquement supprimées.
    __id_commande    INTEGER NOT NULL REFERENCES commande(id) ON DELETE CASCADE__

4 . Le schéma a des colonnes NOT NULL et des clés étrangèeres mais aucune verification pour certaines valeurs
prix peut être négatif, pareil pour quantité


## 0.3 Interroger l'API à la main
5 . On obtien 201. 200 signifie succées générale amsi 201 indique la création d'une nouvelle ressource
6 . C'est Postgres qui bloque la suppression grace à la clé étrangère dans commande_ligne. 
7 . curl -X POST http://localhost:8080/api/commandes -H "Context-Type: application/json" -d '{"numero_table": 6, "lignes": [{"id_plat": 4, "quantité": 2}, {"id_plat": 10, "quantité": 1}]}'

## 0.4 Suivre une requête de bout en bout

| # | Étape | Fichier | Fonction / ligne |
|---|---|---|---|
| 1 | Le formulaire est soumis | `components/PlatForm.vue` | `enregistrer()`|
| 2 | La requête HTTP est construite | `src/api.js` | `requete()` |
| 3 | Vite transmet `/api/...` au port 8080 |`frontend/vite.confid.js` |`defineConfig()` |
| 4 | CodeIgniter choisit le contrôleur | `app/Config:Routes.php`| ligne 13 |
| 5 | Le contrôleur lit le JSON | `app/Controller/Api/ApiController.php`|`donneesJson()` |
| 6 | Les règles de validation sont vérifiées | `app/Validation/GargoteRules.php`| ligne 21 |
| 7 | La ligne est insérée | `app/Services/CommandeService.php` | `creer($donnees)`|
| 8 | Le formulaire prévient l’écran parent | `components/PlatForm.vue`| `emit(…)` |
| 9 | L’écran recharge la liste | `views/CarteView.vue` | `charger()`|

8. Le code métier de la création d'une commande est dans *CommandeServicce.php*, il n'est pas dans le controller Commandes.php car au moment d'une commande, on insère également les données dans deux tables différentes commande` et `commande_ligne`, cette transaction est assurée par le service et le controller recoit seulement la requete http et transmet les données au service

## 0.5 Repérer les notions de vue

| Notion | À quoi ça sert | Votre exemple | Explication |
|---|---|---|---|
| `ref()` | une variable dont le changement met l’écran à jour | CarteView - ligne7 `const plats = ref([])`  | Crée une variable réactive : quand sa valeur change, le template se met à jour automatiquement |
| `computed()` | une valeur calculée à partir d’autres, recalculée automatiquement | Panier - ligne11 `const total = computed(...)` | Calcule une valeur dépendante d’autres refs ; elle est recrée uniquement si ses dépendances changent |
| `v-for` | répéter un élément pour chaque élément d’une liste | CarteView - ligne58 `<li v-for="plat in liste">` | Génère un bloc HTML pour chaque élément d’un tableau, en liant chaque instance à une clé `:key` |
| `v-if` / `v-else` | afficher un élément seulement si une condition est vraie | Panier - ligne18 `<p v-if="lignes.length === 0">` | Conditionnellement monte/d monte un élément dans le DOM selon une condition booléenne |
| `v-model` | lier un champ de formulaire à une variable, dans les deux sens | PlatForm - ligne64 `<input v-model.trim="form.nom">` | Synchronise la valeur d’un champ de saisie avec une variable de données, dans les deux sens |
| `defineProps` | recevoir des données du composant parent | Panier - ligne6 `defineProps({ lignes: ... })` | Déclare les données que le composant parent peut lui transmettre via des attributs |
| `defineEmits` / `emit` | envoyer un événement au composant parent | PlatForm - ligne9 `defineEmits(['enregistre','annule'])` | Permet au composant de signaler un événement (avec éventuel payload) à son parent |
| `onMounted` | exécuter du code quand le composant apparaît | CarteView - ligne40 `onMounted(charger)` |  Appelle une fonction (ici `charger`) une fois le composant inséré dans le DOM |


9. C'est `CommandeView.vue` qui fait le calcul `Panier.vue` renvoye juste un emit à son composant parent, pour que Panier soit réutilisable pour d'autres composant

10. watch() sert à recopier les valeurs d'un plat lorsqu'un parent modifie un autre plat, sans lui on ne pourra modifier qu'un seul plat

## 0.6 Premières modifications

11. Dans Carteview, on fait appelle à l'api pour lister les categorie, et au chargerment de cette view ça charge toutes les categories et les mets dans le prop de PlatForm
    composant : PlatForm
    route : $routes->get('categories', 'Categories::index')
    api.js : categories: {
                    lister: () => requete('GET', '/categories'),
            }
    
    


