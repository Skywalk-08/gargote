ALTER TABLE plat
ADD COLUMN IF NOT EXISTS description TEXT;

ALTER TABLE plat
ADD COLUMN IF NOT EXISTS disponible BOOLEAN NOT NULL DEFAULT TRUE;


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'plat_prix_positif'
    ) THEN
        ALTER TABLE plat
        ADD CONSTRAINT plat_prix_positif CHECK (prix > 0);
    END IF;
END $$;


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'plat_nom_unique'
    ) THEN
        ALTER TABLE plat
        ADD CONSTRAINT plat_nom_unique UNIQUE (nom);
    END IF;
END $$;


CREATE TABLE IF NOT EXISTS plat_du_jour (
    date DATE PRIMARY KEY,
    id_plat INTEGER NOT NULL REFERENCES plat(id) ON DELETE CASCADE
);