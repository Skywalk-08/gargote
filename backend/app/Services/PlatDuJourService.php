<?php

namespace App\Services;

use App\Exceptions\RegleMetierException;
use App\Models\PlatDuJourModel;
use App\Models\PlatModel;

class PlatDuJourService
{
    private PlatModel $plats;

    public function __construct()
    {
        $this->plats = new PlatModel();
    }

    /**
     * @throws RegleMetierException
     */ 
    public function platExiste(int $idPlat)
    {
        $plat = $this->plats->find($idPlat);
        if ($plat === null) {
            throw new RegleMetierException('Plat inconnu.', [
                'id_plat' => 'Ce plat n’existe pas.',
            ], 422);
        }
    }

    public function platDisponible(int $idPlat)
    {
        $plat = $this->plats->find($idPlat);
        if ($plat !== null && !$plat['disponible']) {
            throw new RegleMetierException('Le plat est épuisé : il ne peut pas être plat du jour.', [
                'id_plat' => 'Ce plat n’est pas disponible.',
            ], 409);
        }
    }

    public function changerPlatDuJour(int $idPlat): void
    {
        $platDuJourModel = new PlatDuJourModel();
        $this->platExiste($idPlat);
        $this->platDisponible($idPlat);
        $platDuJourModel->insererOuMettreAJour($idPlat);
    }   
}