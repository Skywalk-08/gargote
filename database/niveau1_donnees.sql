INSERT INTO categorie (libelle)
VALUES ('Goûter')
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO plat (nom, prix, id_categorie, description)
SELECT 'Koba', 1000, id, 'Gâteau traditionnel malgache à base de riz et de cacahuètes'
FROM categorie WHERE libelle = 'Goûter';

INSERT INTO plat (nom, prix, id_categorie, description)
SELECT 'Mofo gasy', 500, id, 'Petite crêpe malgache à base de farine de riz'
FROM categorie WHERE libelle = 'Goûter';
    
INSERT INTO plat (nom, prix, id_categorie, description)
SELECT 'Mokary', 800, id, 'Petite galette sucrée à base de farine de riz et de lait de coco'
FROM categorie WHERE libelle = 'Goûter';

INSERT INTO plat (nom, prix, id_categorie, description)
SELECT 'Godrogodro', 1500, id, 'Un gâteau dense et moelleux confectionné à partir de farine de riz, de cacahuètes concassées, de bananes mûres écrasées et de sucre roux'
FROM categorie WHERE libelle = 'Goûter';

INSERT INTO plat (nom, prix, id_categorie, description)
SELECT 'Menakely', 1200, id, 'Beignets traditionnels malgaches, croustillants à l’extérieur et moelleux à l’intérieur'
FROM categorie WHERE libelle = 'Goûter';

UPDATE plat SET description = 'Soupe de riz aux brèdes traditionnelle de Madagascar' WHERE nom = 'Vary amin''anana';
UPDATE plat SET description = 'Un plat emblématique composé de feuilles de manioc pilées et mijotées longuement avec de la viande de porc' WHERE nom = 'Ravitoto sy henakisoa';
UPDATE plat SET description = 'Le traditionnel poulet au lait de coco de Madagascar' WHERE nom = 'Akoho sy voanio';
UPDATE plat SET description = 'Un bouillon à base de viande et de brède mafana qui procure une légère sensation piquante et anesthésiante en bouche' WHERE nom = 'Romazava';
UPDATE plat SET description = 'Un des ragoûts les plus populaires et réconfortants des Hautes Terres de Madagascar' WHERE nom = 'Henakisoa sy tsaramaso';
UPDATE plat SET disponible = FALSE WHERE nom IN ('Ravitoto sy henakisoa', 'Romazava');


INSERT INTO plat_du_jour (date_jour, id_plat)
SELECT CURRENT_DATE, id FROM plat WHERE nom = 'Akoho sy voanio';

INSERT INTO plat_du_jour (date_jour, id_plat)
SELECT CURRENT_DATE - 1, id FROM plat WHERE nom = 'Henakisoa sy tsaramaso';

INSERT INTO plat_du_jour (date_jour, id_plat)
SELECT CURRENT_DATE - 2, id FROM plat WHERE nom = 'Soupe chinoise';

INSERT INTO plat_du_jour (date_jour, id_plat)
SELECT CURRENT_DATE - 3, id FROM plat WHERE nom = 'Ravitoto sy henakisoa';

INSERT INTO plat_du_jour (date_jour, id_plat)
SELECT CURRENT_DATE - 4, id FROM plat WHERE nom = 'Akoho sy voanio';

INSERT INTO plat_du_jour (date_jour, id_plat)
SELECT CURRENT_DATE - 5, id FROM plat WHERE nom = 'Ravitoto sy henakisoa';

INSERT INTO plat_du_jour (date_jour, id_plat)
SELECT CURRENT_DATE - 6, id FROM plat WHERE nom = 'Vary amin''anana';

INSERT INTO plat (nom, prix, id_categorie, description)
SELECT
    'Test prix zero',
    0,
    id,
    'Plat de test'
FROM categorie
WHERE libelle = 'Plat';

INSERT INTO plat (nom, prix, id_categorie, description)
SELECT
    'Koba',
    1000,
    id,
    'Plat en double'
FROM categorie
WHERE libelle = 'Goûter';


