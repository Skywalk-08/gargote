<?php

namespace App\Models;

use CodeIgniter\Model;

class PlatDuJourModel extends Model
{
    protected $table      = 'plat_du_jour';
    protected $primaryKey = 'date_jour';
    protected $returnType = 'array';

    protected array $casts = [
        'id_plat'           => 'int',
    ];

    protected $allowedFields = ['date_jour', 'id_plat'];

    protected $validationRules = [
        'id_categorie' => 'required|integer',
    ];
    protected $validationMessages = [
        'id_categorie' => [
            'required' => 'Choisissez une catégorie.',
        ],
    ];

    public function insererOuMettreAJour(int $idPlat): void
    {
        $sql = "INSERT INTO plat_du_jour (date_jour, id_plat) VALUES (CURRENT_DATE, ?) ON CONFLICT (date_jour) DO UPDATE SET id_plat = EXCLUDED.id_plat;";
        $this->query($sql, [$idPlat]);
    }

    public function trouverAujourdHui(): ?array
    {
        return $this->where('date_jour', date('Y-m-d'))->first();
    }

}