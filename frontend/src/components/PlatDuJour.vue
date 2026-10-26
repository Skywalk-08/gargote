
<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { api } from '../api'
import { ariary } from '../utils/format'

const props = defineProps({
  modifiable: {
    type: Boolean,
    default: false,
  },
  plats: {
    type: Array,
    default: null,
  },
})

const emit = defineEmits(['choisir'])

const platDuJour = ref(null)
const platsLocaux = ref([])
const selection = ref('')
const message = ref('')
const chargement = ref(false)



const listePlats = computed(() => props.plats ?? platsLocaux.value)

const platsDisponibles = computed(() =>
  listePlats.value.filter((plat) =>
    plat.disponible === true ||
    plat.disponible === 1 ||
    plat.disponible === '1'
  ),
)

function dateLocale() {
  const maintenant = new Date()
  const annee = maintenant.getFullYear()
  const mois = String(maintenant.getMonth() + 1).padStart(2, '0')
  const jour = String(maintenant.getDate()).padStart(2, '0')

  return `${annee}-${mois}-${jour}`
}

// Retrouver l'enregistrement du jour dans les données de l'API.
function trouverEnregistrementDuJour(donnees) {
  if (!donnees) return null

  // L'API peut renvoyer directement un objet.
  if (!Array.isArray(donnees)) {
    return donnees.date_jour ? donnees : null
  }

  // Chercher l'enregistrement correspondant à la date locale.
  const aujourdHui = dateLocale()

  return donnees.find((ligne) => {
    const date = String(ligne.date_jour ?? '').slice(0, 10)
    return date === aujourdHui
  }) ?? null
}

const platActuel = computed(() => {
  if (!platDuJour.value) return null

  if (platDuJour.value.plat) {
    return platDuJour.value.plat
  }

  const id = platDuJour.value.id_plat

  return listePlats.value.find(
    (plat) => Number(plat.id) === Number(id),
  ) ?? null
})

async function chargerPlatDuJour() {
  chargement.value = true
  message.value = ''

  try {
    const donnees = await api.platDuJour.lire()

    console.log('Réponse API plat du jour :', donnees)
    console.log('Date locale :', dateLocale())

    platDuJour.value = trouverEnregistrementDuJour(donnees)

    selection.value = platDuJour.value?.id_plat != null
      ? String(platDuJour.value.id_plat)
      : ''
  } catch (e) {
    message.value = e.message || 'Impossible de charger le plat du jour.'
  } finally {
    chargement.value = false
  }
}

async function chargerPlats() {
  if (props.plats !== null) return

  try {
    platsLocaux.value = await api.plats.lister()
  } catch (e) {
    message.value = e.message || 'Impossible de charger les plats.'
  }
}

async function definirPlat() {
  if (!selection.value) {
    message.value = 'Choisissez un plat disponible.'
    return
  }

  message.value = ''
  chargement.value = true

  try {
    await api.platDuJour.definir(Number(selection.value))

    message.value = 'Le plat du jour a été mis à jour.'

    await chargerPlatDuJour()
  } catch (e) {
    message.value = e.message || 'Impossible de définir le plat du jour.'
  } finally {
    chargement.value = false
  }
}

function choisirPourLaCommande() {
  if (platActuel.value && estDisponible(platActuel.value)) {
    emit('choisir', platActuel.value)
  }
}

function estDisponible(plat) {
  return plat.disponible === true ||
    plat.disponible === 1 ||
    plat.disponible === '1'
}

watch(
  () => props.plats,
  () => {
    if (platDuJour.value?.id_plat != null) {
      selection.value = String(platDuJour.value.id_plat)
    }
  },
)

onMounted(async () => {
  await chargerPlats()
  await chargerPlatDuJour()
})
</script>

<template>
  <section class="panneau plat-du-jour">
    <h2>Plat du jour</h2>
    <p v-if="chargement && !platDuJour">Chargement du plat du jour…</p>
    <p v-if="message" class="message-plat">{{ message }}</p>
    <template v-if="platActuel">
      <button v-if="!modifiable" type="button" class="plat-du-jour-choix" :disabled="!estDisponible(platActuel)" @click="choisirPourLaCommande">
        <span class="plat-du-jour-nom">{{ platActuel.nom }}</span>
        <!-- <span v-if="platActuel.description" class="plat-du-jour-description">{{ platActuel.description }}</span> -->
        <span v-if="!estDisponible(platActuel)" class="plat-indisponible">Épuisé</span> 
        <span class="plat-du-jour-prix">{{ ariary(platActuel.prix) }}</span>
      </button>

      <div v-else class="plat-du-jour-informations">
        <h3>{{ platActuel.nom }}</h3>
        <p v-if="platActuel.description">{{ platActuel.description }}</p>
        <p>{{ ariary(platActuel.prix) }}</p>
      </div>
    </template>

    <p v-else>Aucun plat du jour n'a été défini pour aujourd'hui.</p>

    <div v-if="modifiable" class="plat-du-jour-formulaire">
      <label class="champ">
        <span>Choisir le plat du jour</span>
        <select v-model="selection">
          <option value="" disabled>
            Sélectionner un plat disponible…
          </option>
          <option
            v-for="plat in platsDisponibles":key="plat.id":value="String(plat.id)">{{ plat.nom }} — {{ ariary(plat.prix) }}
          </option>
        </select>
      </label>

      <button type="button" class="bouton" :disabled="chargement || !selection" @click="definirPlat">
        Choisir
      </button>
    </div>

    <button type="button" class="lien" @click="basculerHistorique">
      {{ historiqueVisible ? 'Masquer l’historique' : 'Voir les 7 derniers jours' }}
    </button>

    <div v-if="historiqueVisible" class="historique-plat">
      <p v-if="chargementHistorique">Chargement de l'historique…</p>

      <p v-else-if="historique.length === 0">Aucun historique disponible.</p>

      <ul v-else>
        <li v-for="ligne in historique" :key="ligne.date_jour">
          <span>{{ ligne.date_jour }}</span>

          <span>
            {{
              ligne.plat?.nom
              ?? listePlats.find(
                (plat) => Number(plat.id) === Number(ligne.id_plat),
              )?.nom
              ?? `Plat n° ${ligne.id_plat}`
            }}
          </span>
        </li>
      </ul>
    </div>
  </section>
</template>
