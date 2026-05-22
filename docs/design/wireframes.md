# Wireframes MeteoMada

## Structure globale
- **Top** : Barre de navigation avec titre
- **Main** : Contenu scrollable
- **Bottom** : Barre de navigation (5 onglets)

## Navigation (BottomBar)
1. 🏠 Accueil (météo actuelle)
2. 🔍 Rechercher
3. ⭐ Favoris
4. ⚠️ Alertes
5. ⚙️ Paramètres

---

## ÉCRAN 1 : Accueil

┌─────────────────────────────┐
│ 📍 Antananarivo        🇫🇷  │ ← Barre top (ville + langue)
├─────────────────────────────┤
│                             │
│         ☀️ 28°C            │ ← Icône météo + température
│      Ensoleillé            │ ← Condition texte
│                             │
│  💧 65%  💨 12 km/h  ☀️ UV6│ ← Indicateurs horizontaux
│                             │
│  ┌─────────────────────┐   │
│  │  Prévisions 7 jours  │   │ ← Carte prévisions
│  │  Lun  ☀️  28° 18°   │   │
│  │  Mar  ⛅  26° 17°   │   │
│  │  Mer  🌧️  22° 16°   │   │
│  │  ...                │   │
│  └─────────────────────┘   │
│                             │
│  🌊 Météo marine  >        │ ← Si ville côtière
│  🌾 Calendrier cultural >  │ ← Lien rapide
│                             │
│  ⚠️ Alerte cyclone         │ ← Bannière si active
│     (fond rouge/orange)    │
├─────────────────────────────┤
│ 🏠   🔍   ⭐   ⚠️   ⚙️    │ ← BottomBar
└─────────────────────────────┘

## ÉCRAN 2 : Recherche

┌─────────────────────────────┐
│ 🔍 Rechercher une ville... │ ← Barre de recherche
├─────────────────────────────┤
│  📍 Utiliser ma position   │ ← Option GPS
├─────────────────────────────┤
│  Villes récentes           │
│  ┌─────────────────────┐   │
│  │ 🏙️ Antananarivo    │   │
│  │ 🏙️ Toamasina       │   │
│  │ 🏙️ Antsirabe       │   │
│  └─────────────────────┘   │
│                             │
│  Toutes les régions        │
│  ┌─────────────────────┐   │
│  │ 🌍 Analamanga       │   │
│  │ 🌍 Atsinanana       │   │
│  │ 🌍 Vakinankaratra   │   │
│  │ ...                 │   │
│  └─────────────────────┘   │
├─────────────────────────────┤
│ 🏠   🔍   ⭐   ⚠️   ⚙️    │
└─────────────────────────────┘

## ÉCRAN 3 : Favoris

┌─────────────────────────────┐
│ ⭐ Mes Favoris             │
├─────────────────────────────┤
│                             │
│  ┌─────────────────────┐   │
│  │ 🏙️ Tana     ☀️ 28° │   │ ← Carte favori 1
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ 🏙️ Tamatave ⛅ 26° │   │ ← Carte favori 2
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ 🏙️ Diego     🌧️ 24°│   │ ← Carte favori 3
│  └─────────────────────┘   │
│                             │
│  + Ajouter un favori       │ ← Bouton
│                             │
│  (Si vide)                 │
│  ⭐                        │
│  Aucun favori             │
│  Ajoutez des villes       │
│  pour les retrouver ici   │
├─────────────────────────────┤
│ 🏠   🔍   ⭐   ⚠️   ⚙️    │
└─────────────────────────────┘

## ÉCRAN 4 : Alertes

┌─────────────────────────────┐
│ ⚠️ Alertes cyclone         │
├─────────────────────────────┤
│  🔴 ACTIFS                 │
│  ┌─────────────────────┐   │
│  │ 🌀 Cyclone Freddy  │   │ ← Carte alerte active
│  │ Niveau ROUGE       │   │
│  │ Régions : Est, SE  │   │
│  │ Émis : 22/05 08h   │   │
│  └─────────────────────┘   │
│                             │
│  🟡 TERMINÉS               │
│  ┌─────────────────────┐   │
│  │ 🌀 Cyclone Batsirai│   │ ← Carte alerte passée
│  │ Terminé le 15/05   │   │
│  └─────────────────────┘   │
│                             │
│  (Si vide)                 │
│  ✅                        │
│  Aucune alerte en cours   │
│  Tout va bien !           │
├─────────────────────────────┤
│ 🏠   🔍   ⭐   ⚠️   ⚙️    │
└─────────────────────────────┘

## ÉCRAN 5 : Paramètres

┌─────────────────────────────┐
│ ⚙️ Paramètres              │
├─────────────────────────────┤
│  🌐 Langue                 │
│  ○ Français  ● Malagasy   │
│                             │
│  🔔 Notifications          │
│  [ON] Alertes cyclone      │
│  [ON] Météo quotidienne    │
│  [OFF] Alertes pluie       │
│                             │
│  📍 Position               │
│  ● Utiliser le GPS         │
│  ○ Définir manuellement    │
│                             │
│  ℹ️ À propos               │
│  Version 1.0.0             │
│  Sources : Open-Meteo      │
├─────────────────────────────┤
│ 🏠   🔍   ⭐   ⚠️   ⚙️    │
└─────────────────────────────┘