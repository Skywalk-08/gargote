<?php

namespace App\Controllers\Api;

use App\Exceptions\RegleMetierException;
use App\Models\PlatDuJourModel;
use App\Services\PlatDuJourService;

class PlatDuJour extends ApiController
{
    private PlatDuJourModel $platDuJourModel;
    private PlatDuJourService $platDuJourService;

    public function __construct()
    {
        $this->platDuJourModel = new PlatDuJourModel();
        $this->platDuJourService = new PlatDuJourService();  

    }

    public function index()
    {
        $platDuJour = $this->platDuJourModel->trouverAujourdHui();
        return $this->respond($platDuJour);
    }

    public function update()
    {
        $donnees = $this->request->getJSON(true);
        $idPlat = $donnees['id_plat'] ?? null;

        if (!is_numeric($idPlat) || (int) $idPlat <= 0) {
            return $this->failValidationErrors([
                'id_plat' => 'Un identifiant de plat valide est obligatoire.',
            ]);
        }

        try {
            $this->platDuJourService->changerPlatDuJour((int) $idPlat);

            return $this->respond([
                'message' => 'Le plat du jour a été mis à jour.',
            ]);
        } catch (RegleMetierException $e) {
            return $this->fail($e->getMessage(), $e->getCode());
        }
    }
}
