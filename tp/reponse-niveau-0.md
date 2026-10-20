# Réponses niveau 0

## 0.2
1 . Schéma relationnel
Categorie(<u>id</u>, libelle)
Plat(<u>id</u>, nom, prix, #id_categorie)
Commande(<u>id</u>, date_commande, numero_table)
Commande_ligne(<u>id</u>, #id_commande, #id_plat, quantite, prix_unitaire)

2 . Commande_ligne contient une colonne prix_unitaire 

3 . On ne peut pas supprimer une commande sans avoir supprimer les lignes à cause de la restriction de la clé etrangere not null dans __commande_ligne__

4 . 

## 0.3 Interroger l'API à la main
5 . On obtien 201. 200 signifie succées générale amsi 201 indique la création d'une nouvelle ressource
6 . C'est Postgres qui bloque la suppression. 
7 . 